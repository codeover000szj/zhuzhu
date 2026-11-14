<template>
  <div class="ai-chat-page">
    <PortalPageHeader eyebrow="HERITAGE KNOWLEDGE COMPANION" title="对话 · 非遗" description="带着好奇心出发，在一问一答中发现传统文化的更多可能。" mark="问知" image="/images/hero-scene-6.jpg" />
    <div class="assistant-shell">
    <aside class="assistant-aside"><HeritageKnot /><small>ASK / EXPLORE / LEARN</small><h2>一问之间<br />万象可寻</h2><p>从一件作品到一种工艺，<br />从一个名字到一段文化。</p><div class="prompt-list"><span>不妨从这里开始</span><button v-for="prompt in suggestedPrompts" :key="prompt" type="button" @click="inputMessage = prompt">{{ prompt }} <span>↗</span></button></div><p class="assistant-note">智能回答供学习参考，具体技法与项目信息请结合课程资料和公开档案核实。</p></aside>
    <!-- 对话容器 -->
    <div class="chat-container">
      <!-- 聊天头部 -->
      <div class="chat-header">
        <div class="header-icon">
          <i class="fas fa-comments"></i>
        </div>
        <div class="header-content">
          <h1>非遗智能助手</h1>
          <p>探索非遗知识 · 传承文化瑰宝</p>
        </div>
      </div>
      <a-alert v-if="initializationError" type="warning" :message="initializationError" show-icon>
        <template #action>
          <a-button size="small" :loading="initializing" @click="initializeChat">重新连接</a-button>
        </template>
      </a-alert>
      <!-- 消息列表 -->
      <div class="messages-container" ref="messagesContainer">
        <!-- 欢迎消息 -->
        <div class="message ai-message welcome-message">
          <div class="message-avatar">
            <i class="fas fa-robot"></i>
          </div>
          <div class="message-content">
            <div class="message-text">
              <p class="welcome-title">您好，我是非遗智能助手</p>
              <p>我可以帮您了解：</p>
              <ul class="welcome-list">
                <li>• 非遗作品知识（苏绣、蜀绣、皮影戏、风筝、瓷器等）</li>
                <li>• 传承人信息和代表作品</li>
                <li>• 平台活动和课程推荐</li>
                <li>• 非遗手办商城咨询</li>
              </ul>
              <p class="welcome-footer">请问有什么可以帮助您的吗？</p>
            </div>
          </div>
        </div>

        <!-- 历史消息 -->
        <div
          v-for="(message, index) in messages"
          :key="index"
          class="message"
          :class="message.role === 'user' ? 'user-message' : 'ai-message'"
        >
          <div v-if="message.role === 'assistant'" class="message-avatar">
            <i class="fas fa-robot"></i>
          </div>
          <div class="message-content">
            <div class="message-text" v-html="formatMessage(message.content)"></div>
            <div class="message-time">{{ formatTime(message.createTime) }}</div>
          </div>
          <div v-if="message.role === 'user'" class="message-avatar user-avatar">
            <i class="fas fa-user"></i>
          </div>
        </div>

        <!-- 加载中 -->
        <div v-if="loading" class="message ai-message">
          <div class="message-avatar">
            <i class="fas fa-robot"></i>
          </div>
          <div class="message-content">
            <div class="typing-indicator">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        </div>
      </div>

      <!-- 输入框 -->
      <div class="input-area">
        <a-textarea
          v-model:value="inputMessage"
          placeholder="请输入您的问题..."
          :auto-size="{ minRows: 2, maxRows: 4 }"
          :maxlength="500"
          @pressEnter="handleSend"
        />
        <a-button
          type="primary"
          @click="handleSend"
          :loading="loading"
          :disabled="!inputMessage.trim() || initializing || !currentSessionId"
        >
          <i class="fas fa-paper-plane"></i>
          发送
        </a-button>
      </div>
    </div>
    </div>
  </div>
</template>

<script setup>
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue';
import HeritageKnot from '@/components/frontend/HeritageKnot.vue';
import { ref, watch, onBeforeUnmount, nextTick } from 'vue';
import { message } from 'ant-design-vue';
import { fetchEventSource } from '@microsoft/fetch-event-source';
import { useUserStore } from '@/store/user';
import { marked } from 'marked';
import { 
  createSession as createSessionApi, 
  getSessionList,
  getSessionMessages, 
  getChatStreamUrl 
} from '@/api/AiChatApi';

// 配置 marked
marked.setOptions({
  breaks: true,      // 支持 GitHub 风格的换行（单个换行符转为 <br>）
  gfm: true,         // 启用 GitHub Flavored Markdown
  headerIds: false,  // 不生成 header id
  mangle: false,     // 不转义 HTML
  pedantic: false    // 不使用严格的 Markdown 规则
});

const userStore = useUserStore();
const inputMessage = ref('');
const suggestedPrompts = ['苏绣和蜀绣有哪些区别？', '初学古琴应该从哪里开始？', '如何欣赏青花瓷的纹样？'];
const messages = ref([]);
const loading = ref(false);
const initializing = ref(true);
const initializationError = ref('');
const messagesContainer = ref(null);
const currentSessionId = ref(null);
let conversationVersion = 0;
let activeStream = null;

// 以服务端的当前用户会话为准，刷新页面和清理浏览器缓存都不会丢失数据库记录。
const initializeChat = async () => {
  const version = ++conversationVersion;
  activeStream?.abort();
  activeStream = null;
  currentSessionId.value = null;
  messages.value = [];
  inputMessage.value = '';
  loading.value = false;
  initializing.value = true;
  initializationError.value = '';

  try {
    if (!userStore.userId || !userStore.token) {
      initializationError.value = '请先登录后使用智能助手。';
      return;
    }
    const sessions = await getSessionList({ showDefaultMsg: false });
    if (version !== conversationVersion) return;
    if (!Array.isArray(sessions)) throw new Error('会话列表格式异常');

    let sessionId = sessions[0]?.sessionId;
    let history = [];
    if (sessionId) {
      try {
        history = await getSessionMessages(sessionId, { showDefaultMsg: false });
      } catch (error) {
        // 会话在列表返回后被删除时允许新建；网络和登录错误保留为错误，避免掩盖故障。
        if (error.type !== 'business' || error.message !== '无权访问此会话') throw error;
        sessionId = null;
      }
      if (version !== conversationVersion) return;
    }
    if (!sessionId) {
      sessionId = await createSessionApi('新对话', { showDefaultMsg: false });
      if (version !== conversationVersion) return;
    }
    if (typeof sessionId !== 'string' || !sessionId || !Array.isArray(history)) {
      throw new Error('会话数据格式异常');
    }
    currentSessionId.value = sessionId;
    messages.value = history;
    scrollToBottom();
  } catch (error) {
    if (version !== conversationVersion) return;
    console.error('恢复对话失败:', error);
    initializationError.value = '暂时无法读取对话记录，请检查后端和数据库后重新连接。';
  } finally {
    if (version === conversationVersion) initializing.value = false;
  }
};

// 发送消息
const handleSend = async () => {
  if (!inputMessage.value.trim() || loading.value || initializing.value || !currentSessionId.value) return;

  const version = conversationVersion;

  const userMessage = inputMessage.value.trim();
  inputMessage.value = '';

  // 添加用户消息
  messages.value.push({
    role: 'user',
    content: userMessage,
    createTime: new Date().toISOString()
  });

  scrollToBottom();
  loading.value = true;

  try {
    let aiResponse = '';
    let streamComplete = false;
    
    // 从 userStore 获取 token
    const token = userStore.token;
    if (!token) {
      message.error('请先登录');
      loading.value = false;
      return;
    }
    
    // 检查会话ID
    if (!currentSessionId.value) {
      message.error('会话未初始化，请刷新页面');
      loading.value = false;
      return;
    }
    
    console.log('发送消息到会话:', currentSessionId.value);
    console.log('用户消息:', userMessage);
    
    // 获取SSE流式对话URL
    const apiUrl = getChatStreamUrl();

    // 使用 AbortController 控制请求，防止窗口事件中断
    const abortController = new AbortController();
    activeStream = abortController;
    
    await fetchEventSource(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        sessionId: currentSessionId.value,
        userMessage: userMessage
      }),
      signal: abortController.signal,
      // 关键配置：即使页面隐藏也保持连接
      openWhenHidden: true,
      async onopen(response) {
        if (version !== conversationVersion) throw new Error('当前用户或会话已切换');
        if (!response.ok || !response.headers.get('content-type')?.includes('text/event-stream')) {
          throw new Error(`AI流连接失败（HTTP ${response.status}）`);
        }
      },
      onmessage(event) {
        if (version !== conversationVersion) return;
        console.log('收到SSE消息，event.data:', event.data, '长度:', event.data.length);
        
        if (event.data === '[DONE]') {
          streamComplete = true;
          loading.value = false;
          console.log('SSE流结束，完整响应:', aiResponse);
          return;
        }
        if (event.data.startsWith('[ERROR]')) {
          throw new Error('AI响应失败');
        }
        
        aiResponse += event.data;
        
        // 更新AI消息
        const lastMessage = messages.value[messages.value.length - 1];
        if (lastMessage && lastMessage.role === 'assistant') {
          lastMessage.content = aiResponse;
        } else {
          messages.value.push({
            role: 'assistant',
            content: aiResponse,
            createTime: new Date().toISOString()
          });
        }
        
        scrollToBottom();
      },
      onerror(error) {
        if (version !== conversationVersion) throw error;
        console.error('SSE错误:', error);
        // 抛出错误结束本次请求，避免自动重试重复发送消息。
        throw error;
      },
      onclose() {
        if (version !== conversationVersion) return;
        if (!streamComplete) {
          throw new Error('AI连接在回答完成前已中断');
        }
        // 连接正常关闭
        console.log('SSE连接已关闭');
        loading.value = false;
      }
    });
  } catch (error) {
    if (version !== conversationVersion) return;
    console.error('发送消息失败:', error);
    message.error('AI暂时无法响应，请检查网络或稍后重试');
  } finally {
    if (version === conversationVersion) {
      loading.value = false;
      activeStream = null;
    }
  }
};

// 格式化消息（使用 marked 进行 Markdown 渲染）
const formatMessage = (content) => {
  if (!content) return '';
  try {
    // 确保内容末尾有换行符，marked 才能正确处理最后一段
    const normalizedContent = content.endsWith('\n') ? content : content + '\n';
    
    // 使用 marked 解析 Markdown
    const html = marked.parse(normalizedContent);
    
    // 移除 marked 自动添加的外层 <p> 标签（如果只有一行）
    return html.trim();
  } catch (error) {
    console.error('Markdown 解析失败:', error);
    // 降级处理：保留换行符，转换为 <br/>
    return content
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/\n/g, '<br/>');
  }
};

// 格式化时间
const formatTime = (time) => {
  if (!time) return '';
  const date = new Date(time);
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  return `${hours}:${minutes}`;
};

// 滚动到底部
const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
    }
  });
};

// 账号切换时立即清空旧账号的界面，并丢弃尚未返回的旧请求。
watch(() => [userStore.userId, userStore.token], initializeChat, { immediate: true });
onBeforeUnmount(() => {
  conversationVersion++;
  activeStream?.abort();
});
</script>

<style scoped>
.ai-chat-page {
  min-height: 100vh;
  background: #faf8f3; /* 宣纸白 */
  padding: 32px 20px;
}

.chat-container {
  max-width: 1200px;
  margin: 0 auto;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(139, 69, 19, 0.12);
  border: 1px solid #e8e8e8;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  height: calc(100vh - 64px);
}

.chat-header {
  background: linear-gradient(135deg, #8b4513 0%, #a0522d 100%);
  color: #fff;
  padding: 28px 32px;
  display: flex;
  align-items: center;
  gap: 20px;
  border-bottom: 2px solid rgba(197, 165, 114, 0.3);
}

.header-icon {
  width: 56px;
  height: 56px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  flex-shrink: 0;
}

.header-content h1 {
  margin: 0 0 6px 0;
  font-size: 28px;
  font-weight: 700;
  font-family: 'SimSun', '宋体', serif;
  letter-spacing: 3px;
}

.header-content p {
  margin: 0;
  opacity: 0.95;
  font-size: 15px;
  letter-spacing: 1px;
}

.messages-container {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  background: #faf8f3;
}

.message {
  display: flex;
  margin-bottom: 24px;
  align-items: flex-start;
}

.ai-message {
  justify-content: flex-start;
}

.user-message {
  justify-content: flex-end;
}

.message-avatar {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background: linear-gradient(135deg, #8b4513 0%, #a0522d 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 20px;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(139, 69, 19, 0.3);
}

.user-avatar {
  background: linear-gradient(135deg, #c5a572 0%, #daa520 100%);
}

.message-content {
  max-width: 70%;
  margin: 0 14px;
}

.user-message .message-content {
  margin: 0 14px 0 0;
}

.message-text {
  background: #fff;
  padding: 16px 20px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(139, 69, 19, 0.08);
  border: 1px solid #e8e8e8;
  line-height: 1.8;
  word-wrap: break-word;
  white-space: normal;
  overflow-wrap: break-word;
  color: #2c2c2c;
}

.user-message .message-text {
  background: linear-gradient(135deg, #8b4513 0%, #a0522d 100%);
  color: #fff;
  border: none;
}

/* 欢迎消息样式 */
.welcome-message .message-text {
  background: linear-gradient(135deg, rgba(139, 69, 19, 0.04) 0%, rgba(197, 165, 114, 0.06) 100%);
  border: 2px solid #c5a572;
}

.welcome-title {
  font-size: 20px;
  font-weight: 700;
  color: #8b4513;
  margin-bottom: 16px;
  font-family: 'SimSun', '宋体', serif;
  letter-spacing: 2px;
}

.welcome-list {
  list-style: none;
  padding: 0;
  margin: 16px 0;
}

.welcome-list li {
  padding: 10px 0;
  color: #555;
  font-size: 15px;
  line-height: 1.8;
}

.welcome-footer {
  margin-top: 16px;
  color: #666;
  font-size: 15px;
  font-weight: 500;
}

/* Markdown 样式 */
.message-text :deep(h1),
.message-text :deep(h2),
.message-text :deep(h3),
.message-text :deep(h4),
.message-text :deep(h5),
.message-text :deep(h6) {
  margin-top: 16px;
  margin-bottom: 8px;
  font-weight: 600;
  line-height: 1.4;
  font-family: 'SimSun', '宋体', serif;
  letter-spacing: 1px;
  color: #2c2c2c;
}

.message-text :deep(h1) { font-size: 1.5em; }
.message-text :deep(h2) { font-size: 1.3em; }
.message-text :deep(h3) { font-size: 1.1em; color: #8b4513; }

.message-text :deep(p) {
  margin: 8px 0;
  line-height: 1.8;
  white-space: pre-wrap;
}

.message-text :deep(p:first-child) {
  margin-top: 0;
}

.message-text :deep(p:last-child) {
  margin-bottom: 0;
}

.message-text :deep(ul),
.message-text :deep(ol) {
  margin: 8px 0;
  padding-left: 24px;
}

.message-text :deep(li) {
  margin: 4px 0;
  line-height: 1.8;
  white-space: normal;
}

.message-text :deep(code) {
  background: rgba(139, 69, 19, 0.06);
  padding: 3px 8px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
  color: #8b4513;
}

.message-text :deep(pre) {
  background: #2c2c2c;
  color: #f8f8f2;
  padding: 16px;
  border-radius: 8px;
  overflow-x: auto;
  margin: 16px 0;
  border: 1px solid #e8e8e8;
}

.message-text :deep(pre code) {
  background: transparent;
  padding: 0;
  color: inherit;
}

.message-text :deep(blockquote) {
  border-left: 4px solid #8b4513;
  padding-left: 16px;
  margin: 16px 0;
  color: #666;
  font-style: italic;
  background: rgba(139, 69, 19, 0.03);
  padding: 12px 16px;
  border-radius: 4px;
}

.message-text :deep(a) {
  color: #8b4513;
  text-decoration: none;
  border-bottom: 1px solid transparent;
  transition: border-color 0.3s;
}

.message-text :deep(a:hover) {
  border-bottom-color: #8b4513;
}

.message-text :deep(strong) {
  font-weight: 700;
  color: #2c2c2c;
}

.message-text :deep(em) {
  font-style: italic;
}

.message-text :deep(hr) {
  border: none;
  border-top: 2px solid #e8e8e8;
  margin: 20px 0;
}

.message-text :deep(table) {
  border-collapse: collapse;
  width: 100%;
  margin: 16px 0;
}

.message-text :deep(th),
.message-text :deep(td) {
  border: 1px solid #e8e8e8;
  padding: 10px;
  text-align: left;
}

.message-text :deep(th) {
  background: rgba(139, 69, 19, 0.04);
  font-weight: 600;
  color: #2c2c2c;
}

/* 用户消息中的 Markdown 样式调整 */
.user-message .message-text :deep(code) {
  background: rgba(255, 255, 255, 0.2);
  color: #fff;
}

.user-message .message-text :deep(pre) {
  background: rgba(0, 0, 0, 0.2);
}

.user-message .message-text :deep(a) {
  color: #fff;
  text-decoration: underline;
}

.user-message .message-text :deep(strong) {
  color: #fff;
}

.message-time {
  font-size: 12px;
  color: #999;
  margin-top: 6px;
  padding: 0 4px;
}

.typing-indicator {
  display: flex;
  gap: 8px;
  padding: 16px;
  background: rgba(139, 69, 19, 0.03);
  border-radius: 12px;
}

.typing-indicator span {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #8b4513;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
    opacity: 0.4;
  }
  30% {
    transform: translateY(-12px);
    opacity: 1;
  }
}

.input-area {
  padding: 24px;
  background: #fff;
  border-top: 2px solid #e8e8e8;
  display: flex;
  gap: 16px;
  align-items: flex-end;
}

.input-area :deep(.ant-input) {
  flex: 1;
  border-radius: 8px;
  font-size: 15px;
  border: 1px solid #e8e8e8;
  
  &:focus {
    border-color: #8b4513;
    box-shadow: 0 0 0 2px rgba(139, 69, 19, 0.1);
  }
}

.input-area :deep(.ant-btn-primary) {
  border-radius: 8px;
  height: auto;
  padding: 10px 28px;
  background: linear-gradient(135deg, #8b4513 0%, #a0522d 100%);
  border: none;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 2px;

  &:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(139, 69, 19, 0.4);
  }

  i {
    margin-right: 6px;
  }
}

/* 自定义滚动条 */
.messages-container::-webkit-scrollbar {
  width: 8px;
}

.messages-container::-webkit-scrollbar-track {
  background: rgba(139, 69, 19, 0.05);
  border-radius: 4px;
}

.messages-container::-webkit-scrollbar-thumb {
  background: rgba(139, 69, 19, 0.2);
  border-radius: 4px;
}

.messages-container::-webkit-scrollbar-thumb:hover {
  background: rgba(139, 69, 19, 0.3);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .ai-chat-page {
    padding: 16px 10px;
  }

  .chat-container {
    height: calc(100vh - 32px);
  }

  .chat-header {
    padding: 20px 16px;
  }

  .header-icon {
    width: 48px;
    height: 48px;
    font-size: 24px;
  }

  .header-content h1 {
    font-size: 22px;
    letter-spacing: 2px;
  }

  .header-content p {
    font-size: 13px;
  }

  .messages-container {
    padding: 16px;
  }

  .message-content {
    max-width: 85%;
  }

  .input-area {
    padding: 16px;
    gap: 12px;
  }

  .input-area :deep(.ant-btn-primary) {
    padding: 8px 20px;
  }
}

/* 文化问知空间 */
.ai-chat-page { min-height:0; padding:0; background:transparent; }.assistant-shell { display:grid; grid-template-columns:275px minmax(0,1fr); gap:38px; width:min(1280px,calc(100% - 96px)); margin:auto; padding:44px 0 75px; }.assistant-aside { padding:30px 25px; border:1px solid #d0c0a6; background:#e8e3d5; }.assistant-aside>svg { width:27px; color:#9f6b49; display:block; margin-bottom:30px; }.assistant-aside>small { font:9px Arial,sans-serif; letter-spacing:.14em; color:#aa8c67; }.assistant-aside h2 { font:400 30px/1.8 'Songti SC',serif; letter-spacing:.12em; margin:18px 0; color:#43493c; }.assistant-aside p { font-size:11px; line-height:2.1; color:#9a8c76; }.prompt-list { display:grid; gap:0; margin:35px 0 30px; }.prompt-list>span { color:#8f7859; font-size:11px; margin-bottom:10px; }.prompt-list button { text-align:left; display:flex; align-items:center; justify-content:space-between; gap:15px; border:0; border-bottom:1px solid #d0c2ab; padding:16px 0; background:none; color:#796f5e; font-size:11px; cursor:pointer; line-height:1.8; }.prompt-list button:hover { color:#a4362a; }.assistant-aside .assistant-note { padding-top:20px; border-top:1px solid #d0c2ab; font-size:10px; }
.chat-container { max-width:none; width:100%; margin:0; height:720px; min-width:0; border:1px solid #cdbb9e; border-radius:0; box-shadow:0 6px 30px #51473309; background:#fffdf5; }.chat-header { padding:22px 26px; background:#35463b; border:0; gap:16px; }.header-icon { background:none; width:38px; height:38px; font-size:23px; color:#c8b28a; border:1px solid #c8b28a5c; border-radius:0; }.header-content h1 { color:#efe6d1; font-size:23px; font-weight:400; letter-spacing:.15em; }.header-content p { font-size:10px; color:#d0c3a7; }.messages-container { padding:26px; background:#f8f5ed; }.message-avatar { background:#455a4b; width:32px; height:32px; font-size:15px; border-radius:2px; box-shadow:none; }.user-avatar { background:#ae8860; }.message-content { max-width:85%; margin-inline:12px; }.message-text { border-radius:0 7px 7px 7px; padding:16px 19px; border:1px solid #dfd3bd; box-shadow:none; color:#6b685c; font-size:12px; }.welcome-message .message-text { background:#eeeadf; border:1px solid #d3c3a7; }.welcome-title { font-weight:400; font-size:20px; color:#59614c; }.welcome-list { margin:15px 0; }.welcome-list li { padding:5px 0; color:#8b806d; font-size:12px; }.welcome-footer { font-size:12px; color:#97856a; }.user-message .message-text { background:#435c4c; border:1px solid #435c4c; }.message-time { font-size:9px; color:#ab9e85; margin-top:9px; }.input-area { padding:20px; background:#efeadf; border-top:1px solid #d3c3a7; gap:12px; }.input-area :deep(.ant-input) { font-size:12px; border-radius:0; }.input-area :deep(.ant-btn-primary) { background:#a4362a; border-radius:0; font-size:12px; padding:10px 19px; }.typing-indicator { border-radius:0; }.typing-indicator span { background:#98764c; }
@media(max-width:900px) { .assistant-shell { grid-template-columns:1fr; gap:25px; }.assistant-aside { display:none; }.chat-container { height:690px; } }
@media(max-width:600px) { .assistant-shell { width:calc(100% - 32px); padding:25px 0 45px; }.chat-container { height:650px; }.chat-header { padding:20px 17px; }.header-content h1 { font-size:20px; }.messages-container { padding:20px 12px; }.message-content { max-width:calc(100% - 47px); margin-inline:8px; }.message-text { padding:14px; }.welcome-list li { font-size:11px; }.welcome-title { font-size:17px; }.input-area { padding:13px; gap:9px; }.input-area :deep(.ant-btn-primary) { padding:10px 12px; font-size:11px; } }
</style>

