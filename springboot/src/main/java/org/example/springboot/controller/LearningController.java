package org.example.springboot.controller;

import jakarta.annotation.Resource;
import org.example.springboot.common.Result;
import org.example.springboot.enums.UserType;
import org.example.springboot.exception.BusinessException;
import org.example.springboot.util.JwtTokenUtils;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/learning")
public class LearningController {

    @Resource
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/teacher/courses")
    public Result<List<Map<String, Object>>> teacherCourses() {
        long userId = requireUser();
        String role = JwtTokenUtils.getCurrentUserType();
        if (UserType.ADMIN.getCode().equals(role)) {
            return Result.success(jdbcTemplate.queryForList("SELECT c.id, c.title, c.level, c.description, c.status, c.teacher_id AS teacherId, (SELECT COUNT(*) FROM course_chapter ch WHERE ch.course_id = c.id) AS chapterCount FROM course c ORDER BY c.update_time DESC"));
        }
        if (!UserType.TEACHER.getCode().equals(role)) {
            throw new BusinessException("FORBIDDEN", "仅传承人/教师可以进入工作区");
        }
        return Result.success(jdbcTemplate.queryForList("SELECT c.id, c.title, c.level, c.description, c.status, c.teacher_id AS teacherId, (SELECT COUNT(*) FROM course_chapter ch WHERE ch.course_id = c.id) AS chapterCount FROM course c WHERE c.teacher_id = ? ORDER BY c.update_time DESC", userId));
    }

    @GetMapping("/mine")
    public Result<List<Map<String, Object>>> myCourses() {
        long userId = requireUser();
        String sql = "SELECT e.course_id AS courseId, c.title, c.level, c.cover_file_id AS coverFileId, " +
                "(SELECT COUNT(*) FROM course_chapter ch WHERE ch.course_id = c.id) AS totalChapters, " +
                "(SELECT COUNT(*) FROM course_chapter_progress p WHERE p.user_id = e.user_id AND p.course_id = c.id) AS completedChapters " +
                "FROM course_enrollment e JOIN course c ON c.id = e.course_id " +
                "WHERE e.user_id = ? ORDER BY e.updated_at DESC";
        return Result.success(jdbcTemplate.queryForList(sql, userId));
    }

    @GetMapping("/courses/{courseId}/status")
    public Result<Map<String, Object>> courseStatus(@PathVariable String courseId) {
        long userId = requireUser();
        Map<String, Object> course = courseInfo(courseId);
        boolean manager = isManager(course);
        boolean enrolled = enrolled(userId, courseId);
        if (!manager && !enrolled && !Integer.valueOf(1).equals(number(course.get("status")))) {
            throw new BusinessException("课程尚未开放");
        }
        List<Long> completed = enrolled
                ? jdbcTemplate.queryForList("SELECT chapter_id FROM course_chapter_progress WHERE user_id = ? AND course_id = ?", Long.class, userId, courseId)
                : List.of();
        Map<String, Object> status = new LinkedHashMap<>();
        status.put("enrolled", enrolled);
        status.put("completedChapterIds", completed);
        status.put("canManage", manager);
        return Result.success(status);
    }

    @PostMapping("/courses/{courseId}/enroll")
    public Result<Map<String, Object>> enroll(@PathVariable String courseId) {
        long userId = requireUser();
        Map<String, Object> course = courseInfo(courseId);
        if (!Integer.valueOf(1).equals(number(course.get("status")))) {
            throw new BusinessException("该课程尚未开放报名");
        }
        jdbcTemplate.update("INSERT IGNORE INTO course_enrollment (user_id, course_id) VALUES (?, ?)", userId, courseId);
        Map<String, Object> status = new LinkedHashMap<>();
        status.put("enrolled", true);
        status.put("completedChapterIds", List.of());
        status.put("canManage", false);
        return Result.success(status);
    }

    @PostMapping("/courses/{courseId}/chapters/{chapterId}/complete")
    public Result<Void> completeChapter(@PathVariable String courseId, @PathVariable Long chapterId) {
        long userId = requireUser();
        requireEnrollment(userId, courseId);
        Integer chapterCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM course_chapter WHERE id = ? AND course_id = ?", Integer.class, chapterId, courseId);
        if (chapterCount == null || chapterCount == 0) {
            throw new BusinessException("章节不属于该课程");
        }
        jdbcTemplate.update("INSERT IGNORE INTO course_chapter_progress (user_id, course_id, chapter_id) VALUES (?, ?, ?)", userId, courseId, chapterId);
        return Result.success();
    }

    @GetMapping("/courses/{courseId}/resources")
    public Result<List<Map<String, Object>>> resources(@PathVariable String courseId) {
        long userId = requireUser();
        Map<String, Object> course = courseInfo(courseId);
        requireCourseAccess(course, userId);
        return Result.success(jdbcTemplate.queryForList(
                "SELECT id, course_id AS courseId, title, resource_type AS resourceType, resource_url AS resourceUrl, description, created_at AS createdAt " +
                        "FROM course_resource WHERE course_id = ? ORDER BY created_at DESC", courseId));
    }

    @PostMapping("/courses/{courseId}/resources")
    public Result<Map<String, Object>> createResource(@PathVariable String courseId, @RequestBody Map<String, Object> body) {
        long userId = requireCourseManager(courseId);
        String title = requiredText(body, "title", 160);
        String type = optionalText(body, "resourceType", 20, "LINK").toUpperCase();
        if (!List.of("LINK", "VIDEO", "DOCUMENT").contains(type)) {
            throw new BusinessException("资源类型无效");
        }
        String url = requiredText(body, "resourceUrl", 1000);
        if (!url.startsWith("https://") && !url.startsWith("http://") && !url.startsWith("/files/")) {
            throw new BusinessException("资源地址需使用 http(s) 链接或 /files/ 本地路径");
        }
        String description = optionalText(body, "description", 500, "");
        jdbcTemplate.update("INSERT INTO course_resource (course_id, creator_id, title, resource_type, resource_url, description) VALUES (?, ?, ?, ?, ?, ?)",
                courseId, userId, title, type, url, description);
        Long id = jdbcTemplate.queryForObject("SELECT LAST_INSERT_ID()", Long.class);
        Map<String, Object> saved = new LinkedHashMap<>();
        saved.put("id", id);
        saved.put("title", title);
        saved.put("resourceType", type);
        saved.put("resourceUrl", url);
        saved.put("description", description);
        return Result.success(saved);
    }

    @DeleteMapping("/resources/{resourceId}")
    public Result<Void> deleteResource(@PathVariable Long resourceId) {
        Map<String, Object> rows = first("SELECT course_id FROM course_resource WHERE id = ?", resourceId);
        if (rows == null) {
            throw new BusinessException("资源不存在");
        }
        requireCourseManager(String.valueOf(rows.get("course_id")));
        jdbcTemplate.update("DELETE FROM course_resource WHERE id = ?", resourceId);
        return Result.success();
    }

    @GetMapping("/courses/{courseId}/tasks")
    public Result<List<Map<String, Object>>> tasks(@PathVariable String courseId) {
        long userId = requireUser();
        Map<String, Object> course = courseInfo(courseId);
        requireCourseAccess(course, userId);
        boolean manager = isManager(course);
        String sql = "SELECT t.id, t.course_id AS courseId, t.title, t.description, t.due_at AS dueAt, t.status, t.created_at AS createdAt, " +
                "s.status AS submissionStatus, s.score, s.feedback, s.submitted_at AS submittedAt " +
                "FROM learning_task t LEFT JOIN learning_submission s ON s.task_id = t.id AND s.user_id = ? " +
                "WHERE t.course_id = ? " + (manager ? "" : "AND t.status = 1 ") + "ORDER BY t.created_at DESC";
        return Result.success(jdbcTemplate.queryForList(sql, userId, courseId));
    }

    @PostMapping("/courses/{courseId}/tasks")
    public Result<Map<String, Object>> createTask(@PathVariable String courseId, @RequestBody Map<String, Object> body) {
        long userId = requireCourseManager(courseId);
        String title = requiredText(body, "title", 160);
        String description = optionalText(body, "description", 5000, "");
        Timestamp dueAt = parseDueAt(optionalText(body, "dueAt", 32, ""));
        jdbcTemplate.update("INSERT INTO learning_task (course_id, creator_id, title, description, due_at) VALUES (?, ?, ?, ?, ?)",
                courseId, userId, title, description, dueAt);
        Long id = jdbcTemplate.queryForObject("SELECT LAST_INSERT_ID()", Long.class);
        Map<String, Object> created = new LinkedHashMap<>();
        created.put("id", id);
        created.put("courseId", courseId);
        created.put("title", title);
        created.put("description", description);
        created.put("dueAt", dueAt);
        return Result.success(created);
    }

    @PostMapping("/courses/{courseId}/tasks/{taskId}/submit")
    public Result<Void> submitTask(@PathVariable String courseId, @PathVariable Long taskId, @RequestBody Map<String, Object> body) {
        long userId = requireUser();
        if (UserType.TEACHER.getCode().equals(JwtTokenUtils.getCurrentUserType()) || UserType.ADMIN.getCode().equals(JwtTokenUtils.getCurrentUserType())) {
            throw new BusinessException("教师与管理员不能提交学习作业");
        }
        requireEnrollment(userId, courseId);
        Integer taskCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM learning_task WHERE id = ? AND course_id = ? AND status = 1", Integer.class, taskId, courseId);
        if (taskCount == null || taskCount == 0) {
            throw new BusinessException("任务不存在或已关闭");
        }
        String content = optionalText(body, "content", 10000, "");
        String evidenceUrl = optionalText(body, "evidenceUrl", 1000, "");
        if (content.isBlank() && evidenceUrl.isBlank()) {
            throw new BusinessException("请填写学习记录或作品链接");
        }
        jdbcTemplate.update("INSERT INTO learning_submission (task_id, user_id, content, evidence_url, status) VALUES (?, ?, ?, ?, 0) " +
                        "ON DUPLICATE KEY UPDATE content = VALUES(content), evidence_url = VALUES(evidence_url), status = 0, score = NULL, feedback = NULL, submitted_at = CURRENT_TIMESTAMP, reviewed_at = NULL",
                taskId, userId, content, evidenceUrl);
        return Result.success();
    }

    @GetMapping("/tasks/{taskId}/submissions")
    public Result<List<Map<String, Object>>> submissions(@PathVariable Long taskId) {
        Map<String, Object> task = first("SELECT course_id FROM learning_task WHERE id = ?", taskId);
        if (task == null) {
            throw new BusinessException("任务不存在");
        }
        requireCourseManager(String.valueOf(task.get("course_id")));
        return Result.success(jdbcTemplate.queryForList(
                "SELECT s.id, s.user_id AS userId, COALESCE(u.name, u.username) AS userName, s.content, s.evidence_url AS evidenceUrl, s.status, s.score, s.feedback, s.submitted_at AS submittedAt " +
                        "FROM learning_submission s JOIN user u ON u.id = s.user_id WHERE s.task_id = ? ORDER BY s.status ASC, s.submitted_at DESC", taskId));
    }

    @PutMapping("/submissions/{submissionId}/review")
    public Result<Void> reviewSubmission(@PathVariable Long submissionId, @RequestBody Map<String, Object> body) {
        Map<String, Object> submission = first("SELECT t.course_id AS course_id FROM learning_submission s JOIN learning_task t ON t.id = s.task_id WHERE s.id = ?", submissionId);
        if (submission == null) {
            throw new BusinessException("作业提交不存在");
        }
        requireCourseManager(String.valueOf(submission.get("course_id")));
        BigDecimal score;
        try {
            score = new BigDecimal(String.valueOf(body.get("score")));
        } catch (Exception e) {
            throw new BusinessException("评分需为 0 到 100 之间的数字");
        }
        if (score.compareTo(BigDecimal.ZERO) < 0 || score.compareTo(BigDecimal.valueOf(100)) > 0) {
            throw new BusinessException("评分需为 0 到 100 之间的数字");
        }
        String feedback = requiredText(body, "feedback", 5000);
        jdbcTemplate.update("UPDATE learning_submission SET status = 1, score = ?, feedback = ?, reviewed_at = CURRENT_TIMESTAMP WHERE id = ?", score, feedback, submissionId);
        return Result.success();
    }

    @GetMapping("/questions")
    public Result<List<Map<String, Object>>> questions(@RequestParam(required = false) String courseId) {
        List<Map<String, Object>> questions = courseId == null || courseId.isBlank()
                ? jdbcTemplate.queryForList("SELECT q.id, q.course_id AS courseId, c.title AS courseTitle, q.kind, q.title, q.content, COALESCE(u.name, u.username) AS userName, q.created_at AS createdAt FROM course_question q JOIN course c ON c.id = q.course_id JOIN user u ON u.id = q.user_id WHERE c.status = 1 ORDER BY q.created_at DESC LIMIT 60")
                : jdbcTemplate.queryForList("SELECT q.id, q.course_id AS courseId, c.title AS courseTitle, q.kind, q.title, q.content, COALESCE(u.name, u.username) AS userName, q.created_at AS createdAt FROM course_question q JOIN course c ON c.id = q.course_id JOIN user u ON u.id = q.user_id WHERE q.course_id = ? AND c.status = 1 ORDER BY q.created_at DESC LIMIT 60", courseId);
        for (Map<String, Object> question : questions) {
            question.put("replies", jdbcTemplate.queryForList(
                    "SELECT r.id, r.role_type AS roleType, COALESCE(u.name, u.username) AS userName, r.content, r.created_at AS createdAt FROM course_question_reply r JOIN user u ON u.id = r.user_id WHERE r.question_id = ? ORDER BY r.created_at ASC",
                    question.get("id")));
        }
        return Result.success(questions);
    }

    @PostMapping("/questions")
    public Result<Map<String, Object>> createQuestion(@RequestBody Map<String, Object> body) {
        long userId = requireUser();
        String courseId = requiredText(body, "courseId", 50);
        Map<String, Object> course = courseInfo(courseId);
        if (!Integer.valueOf(1).equals(number(course.get("status")))) {
            throw new BusinessException("课程未开放讨论");
        }
        String kind = optionalText(body, "kind", 20, "QUESTION").toUpperCase();
        if (!List.of("QUESTION", "COMMENT").contains(kind)) {
            throw new BusinessException("讨论类型无效");
        }
        String title = optionalText(body, "title", 160, "");
        if (title.isBlank()) {
            title = kind.equals("COMMENT") ? "课程讨论" : "新问题";
        }
        String content = requiredText(body, "content", 10000);
        jdbcTemplate.update("INSERT INTO course_question (course_id, user_id, kind, title, content) VALUES (?, ?, ?, ?, ?)", courseId, userId, kind, title, content);
        Long id = jdbcTemplate.queryForObject("SELECT LAST_INSERT_ID()", Long.class);
        Map<String, Object> created = new LinkedHashMap<>();
        created.put("id", id);
        return Result.success(created);
    }

    @PostMapping("/questions/{questionId}/replies")
    public Result<Void> reply(@PathVariable Long questionId, @RequestBody Map<String, Object> body) {
        long userId = requireUser();
        Map<String, Object> question = first("SELECT course_id FROM course_question WHERE id = ?", questionId);
        if (question == null) {
            throw new BusinessException("讨论内容不存在");
        }
        String role = JwtTokenUtils.getCurrentUserType();
        if (UserType.TEACHER.getCode().equals(role) || UserType.ADMIN.getCode().equals(role)) {
            requireCourseManager(String.valueOf(question.get("course_id")));
        }
        String content = requiredText(body, "content", 10000);
        jdbcTemplate.update("INSERT INTO course_question_reply (question_id, user_id, role_type, content) VALUES (?, ?, ?, ?)", questionId, userId, role, content);
        return Result.success();
    }

    private long requireUser() {
        Long userId = JwtTokenUtils.getCurrentUserId();
        if (userId == null || JwtTokenUtils.getCurrentUserType() == null) {
            throw new BusinessException("UNAUTHORIZED", "请先登录后继续");
        }
        return userId;
    }

    private long requireCourseManager(String courseId) {
        long userId = requireUser();
        Map<String, Object> course = courseInfo(courseId);
        if (!isManager(course)) {
            throw new BusinessException("FORBIDDEN", "只能管理自己负责的课程");
        }
        return userId;
    }

    private boolean isManager(Map<String, Object> course) {
        String role = JwtTokenUtils.getCurrentUserType();
        if (UserType.ADMIN.getCode().equals(role)) {
            return true;
        }
        Object ownerId = course.get("teacher_id");
        return UserType.TEACHER.getCode().equals(role) && ownerId instanceof Number
                && ((Number) ownerId).longValue() == JwtTokenUtils.getCurrentUserId();
    }

    private void requireCourseAccess(Map<String, Object> course, long userId) {
        if (isManager(course)) {
            return;
        }
        if (!Integer.valueOf(1).equals(number(course.get("status")))) {
            throw new BusinessException("课程尚未开放");
        }
        requireEnrollment(userId, String.valueOf(course.get("id")));
    }

    private Map<String, Object> courseInfo(String courseId) {
        Map<String, Object> course = first("SELECT id, status, teacher_id FROM course WHERE id = ?", courseId);
        if (course == null) {
            throw new BusinessException("课程不存在");
        }
        return course;
    }

    private void requireEnrollment(long userId, String courseId) {
        Integer count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM course_enrollment WHERE user_id = ? AND course_id = ?", Integer.class, userId, courseId);
        if (count == null || count == 0) {
            throw new BusinessException("请先加入课程");
        }
    }

    private boolean enrolled(long userId, String courseId) {
        Integer count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM course_enrollment WHERE user_id = ? AND course_id = ?", Integer.class, userId, courseId);
        return count != null && count > 0;
    }

    private Map<String, Object> first(String sql, Object... args) {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, args);
        return rows.isEmpty() ? null : rows.get(0);
    }

    private Integer number(Object value) {
        return value instanceof Number ? ((Number) value).intValue() : null;
    }

    private String requiredText(Map<String, Object> body, String key, int maxLength) {
        String value = optionalText(body, key, maxLength, "");
        if (value.isBlank()) {
            throw new BusinessException(key + "不能为空");
        }
        return value;
    }

    private String optionalText(Map<String, Object> body, String key, int maxLength, String fallback) {
        Object raw = body.get(key);
        String value = raw == null ? fallback : String.valueOf(raw).trim();
        if (value.length() > maxLength) {
            throw new BusinessException(key + "长度不能超过" + maxLength + "个字符");
        }
        return value;
    }

    private Timestamp parseDueAt(String value) {
        if (value.isBlank()) {
            return null;
        }
        try {
            return Timestamp.valueOf(LocalDateTime.parse(value));
        } catch (Exception e) {
            throw new BusinessException("截止时间格式无效");
        }
    }
}
