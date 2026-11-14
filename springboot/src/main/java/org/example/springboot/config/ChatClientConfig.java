package org.example.springboot.config;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * ChatClient 配置类
 * 
 * @author system
 */
@Configuration
public class ChatClientConfig {
    /**
     * 配置 ChatClient - OpenAI兼容的聊天客户端
     * 
     * @param openAiChatModel OpenAI Chat模型（由Spring AI自动配置）
     * @return ChatClient 实例
     */
    @Bean("open-ai")
    public ChatClient openAIChatClient(OpenAiChatModel openAiChatModel) {
        // 历史由服务按已验证的会话从 MySQL 加载，避免进程内记忆重启丢失或重复追加。
        return ChatClient.builder(openAiChatModel)
                .build();
    }
}

