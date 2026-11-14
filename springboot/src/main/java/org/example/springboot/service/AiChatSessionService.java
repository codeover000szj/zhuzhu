package org.example.springboot.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.springboot.entity.AiChatMessage;
import org.example.springboot.entity.AiChatSession;
import org.example.springboot.mapper.AiChatMessageMapper;
import org.example.springboot.mapper.AiChatSessionMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

/**
 * AI聊天会话管理服务
 * @author system
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiChatSessionService {

    private static final int MAX_CONTEXT_MESSAGES = 30;
    private final AiChatSessionMapper sessionMapper;
    private final AiChatMessageMapper messageMapper;

    /**
     * 创建新会话
     */
    @Transactional
    public String createSession(Long userId, String title) {
        String sessionId = UUID.randomUUID().toString();
        
        AiChatSession session = AiChatSession.builder()
                .sessionId(sessionId)
                .userId(userId)
                .title(title != null ? title : "新对话")
                .build();
        
        sessionMapper.insert(session);
        log.info("创建新会话，sessionId: {}, userId: {}", sessionId, userId);
        
        return sessionId;
    }

    /**
     * 获取用户的所有会话
     */
    public List<AiChatSession> getUserSessions(Long userId) {
        LambdaQueryWrapper<AiChatSession> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AiChatSession::getUserId, userId);
        wrapper.orderByDesc(AiChatSession::getUpdateTime);
        wrapper.orderByDesc(AiChatSession::getId);
        
        return sessionMapper.selectList(wrapper);
    }

    /**
     * 获取会话详情
     */
    public AiChatSession getSessionById(String sessionId) {
        LambdaQueryWrapper<AiChatSession> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AiChatSession::getSessionId, sessionId);
        
        return sessionMapper.selectOne(wrapper);
    }

    /**
     * 获取会话的所有消息
     */
    public List<AiChatMessage> getSessionMessages(String sessionId) {
        LambdaQueryWrapper<AiChatMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AiChatMessage::getSessionId, sessionId);
        wrapper.orderByAsc(AiChatMessage::getCreateTime);
        wrapper.orderByAsc(AiChatMessage::getId);
        
        return messageMapper.selectList(wrapper);
    }

    /**
     * 每次对话从数据库读取最近的上下文，服务重启后也能继续之前的话题。
     */
    public List<AiChatMessage> getRecentSessionMessages(String sessionId) {
        LambdaQueryWrapper<AiChatMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AiChatMessage::getSessionId, sessionId)
                .orderByDesc(AiChatMessage::getCreateTime)
                .orderByDesc(AiChatMessage::getId)
                .last("LIMIT " + MAX_CONTEXT_MESSAGES);
        List<AiChatMessage> messages = new ArrayList<>(messageMapper.selectList(wrapper));
        Collections.reverse(messages);
        return messages;
    }

    /**
     * 保存消息
     */
    @Transactional
    public void saveMessage(String sessionId, String role, String content) {
        AiChatMessage message = AiChatMessage.builder()
                .sessionId(sessionId)
                .role(role)
                .content(content)
                .build();
        
        messageMapper.insert(message);
        sessionMapper.update(null, new LambdaUpdateWrapper<AiChatSession>()
                .eq(AiChatSession::getSessionId, sessionId)
                .set(AiChatSession::getUpdateTime, LocalDateTime.now()));
        log.debug("保存消息，sessionId: {}, role: {}", sessionId, role);
    }

    /**
     * 更新会话标题
     */
    @Transactional
    public void updateSessionTitle(String sessionId, String title) {
        LambdaQueryWrapper<AiChatSession> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AiChatSession::getSessionId, sessionId);
        
        AiChatSession session = sessionMapper.selectOne(wrapper);
        if (session != null) {
            session.setTitle(title);
            sessionMapper.updateById(session);
            log.info("更新会话标题，sessionId: {}, title: {}", sessionId, title);
        }
    }

    /**
     * 删除会话（包括所有消息）
     */
    @Transactional
    public void deleteSession(String sessionId) {
        // 删除会话
        LambdaQueryWrapper<AiChatSession> sessionWrapper = new LambdaQueryWrapper<>();
        sessionWrapper.eq(AiChatSession::getSessionId, sessionId);
        sessionMapper.delete(sessionWrapper);
        
        // 删除消息
        LambdaQueryWrapper<AiChatMessage> messageWrapper = new LambdaQueryWrapper<>();
        messageWrapper.eq(AiChatMessage::getSessionId, sessionId);
        messageMapper.delete(messageWrapper);
        
        log.info("删除会话，sessionId: {}", sessionId);
    }

    /**
     * 验证会话是否属于用户
     */
    public boolean isSessionOwnedByUser(String sessionId, Long userId) {
        AiChatSession session = getSessionById(sessionId);
        return session != null && session.getUserId().equals(userId);
    }
}

