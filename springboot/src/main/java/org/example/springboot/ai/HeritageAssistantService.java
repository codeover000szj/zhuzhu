package org.example.springboot.ai;


import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.springboot.entity.AiChatMessage;
import org.example.springboot.service.AiChatSessionService;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.util.ArrayList;
import java.util.List;

/**
 * 非遗智能助手AI服务
 * @author system
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class HeritageAssistantService {

    private static final String AI_NOT_CONFIGURED_MESSAGE = "智能问答暂未配置服务密钥，请联系管理员完成配置后重试。";
    private static final String UNCONFIGURED_API_KEY = "local-unconfigured-key";

    @Qualifier("open-ai")
    private final ChatClient chatClient;

    @Value("${spring.ai.openai.api-key:}")
    private String apiKey;

    @Autowired
    private AiChatSessionService sessionService;

    /**
     * 流式对话（带会话记忆）
     * 
     * @param sessionId 会话ID
     * @param userMessage 用户消息
     * @return Flux流式响应
     */
    public Flux<String> chatStream(String sessionId, String userMessage) {
        log.info("开始AI对话，sessionId: {}, userMessage: {}", sessionId, userMessage);
        
        // 先读取历史再保存本次提问，确保当前消息只进入模型上下文一次。
        List<Message> history = loadHistory(sessionId);
        sessionService.saveMessage(sessionId, "user", userMessage);

        if (!isConfigured()) {
            sessionService.saveMessage(sessionId, "assistant", AI_NOT_CONFIGURED_MESSAGE);
            return Flux.just(AI_NOT_CONFIGURED_MESSAGE);
        }
        
        // 构建流式响应
        Flux<String> responseFlux = chatClient.prompt()
                .system(PromptManage.HERITAGE_ASSISTANT_PROMPT)
                .messages(history)
                .user(userMessage)
                .stream()
                .content();
        
        // 收集完整响应并保存
        StringBuilder fullResponse = new StringBuilder();
        return responseFlux
                .doOnNext(fullResponse::append)
                .doOnComplete(() -> {
                    String assistantMessage = fullResponse.toString();
                    sessionService.saveMessage(sessionId, "assistant", assistantMessage);
                    log.info("AI对话完成，sessionId: {}, 响应长度: {}", sessionId, assistantMessage.length());
                })
                .doOnError(error -> {
                    log.error("AI对话失败，sessionId: {}", sessionId, error);
                });
    }

    /**
     * 非流式对话（一次性返回）
     * 
     * @param sessionId 会话ID
     * @param userMessage 用户消息
     * @return AI响应内容
     */
    public String chat(String sessionId, String userMessage) {
        log.info("开始AI对话（非流式），sessionId: {}, userMessage: {}", sessionId, userMessage);
        
        List<Message> history = loadHistory(sessionId);
        sessionService.saveMessage(sessionId, "user", userMessage);

        if (!isConfigured()) {
            sessionService.saveMessage(sessionId, "assistant", AI_NOT_CONFIGURED_MESSAGE);
            return AI_NOT_CONFIGURED_MESSAGE;
        }
        
        try {
            // 调用AI
            String assistantMessage = chatClient.prompt()
                    .system(PromptManage.HERITAGE_ASSISTANT_PROMPT)
                    .messages(history)
                    .user(userMessage)
                    .call()
                    .content();
            
            // 保存AI响应
            sessionService.saveMessage(sessionId, "assistant", assistantMessage);
            log.info("AI对话完成（非流式），sessionId: {}, 响应长度: {}", sessionId, assistantMessage.length());
            
            return assistantMessage;
            
        } catch (Exception e) {
            log.error("AI对话失败，sessionId: {}", sessionId, e);
            throw new RuntimeException("AI服务调用失败：" + e.getMessage(), e);
        }
    }

    private List<Message> loadHistory(String sessionId) {
        List<Message> history = new ArrayList<>();
        for (AiChatMessage message : sessionService.getRecentSessionMessages(sessionId)) {
            if (message.getContent() == null || message.getContent().isBlank()) {
                continue;
            }
            if ("user".equals(message.getRole())) {
                history.add(new UserMessage(message.getContent()));
            } else if ("assistant".equals(message.getRole())) {
                history.add(new AssistantMessage(message.getContent()));
            }
        }
        return history;
    }

    private boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank() && !UNCONFIGURED_API_KEY.equals(apiKey);
    }
}

