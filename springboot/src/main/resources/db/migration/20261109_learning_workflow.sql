-- Run once against the existing heritage_db before deploying this version.
-- This is an additive migration; it preserves the current catalog, courses, and media.
ALTER TABLE course
    ADD COLUMN teacher_id BIGINT NULL COMMENT '负责课程的传承人/教师用户ID',
    ADD INDEX idx_course_teacher (teacher_id);

ALTER TABLE heritage_item
    ADD COLUMN archive_code VARCHAR(60) NULL COMMENT '档案编号',
    ADD COLUMN process_summary VARCHAR(1000) NULL COMMENT '工艺流程摘要',
    ADD COLUMN material_list VARCHAR(500) NULL COMMENT '主要材料',
    ADD COLUMN preservation_notes VARCHAR(1000) NULL COMMENT '保存与修复记录',
    ADD COLUMN rights_notice VARCHAR(500) NULL COMMENT '授权与转载说明';

UPDATE heritage_item
SET archive_code = CONCAT('ICH-', id)
WHERE archive_code IS NULL OR archive_code = '';

CREATE TABLE course_enrollment (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    course_id VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_course_enrollment (user_id, course_id),
    KEY idx_enrollment_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程学习报名';

CREATE TABLE course_chapter_progress (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    course_id VARCHAR(50) NOT NULL,
    chapter_id BIGINT NOT NULL,
    completed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_chapter_progress (user_id, chapter_id),
    KEY idx_progress_course (user_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='章节学习进度';

CREATE TABLE course_resource (
    id BIGINT NOT NULL AUTO_INCREMENT,
    course_id VARCHAR(50) NOT NULL,
    creator_id BIGINT NOT NULL,
    title VARCHAR(160) NOT NULL,
    resource_type VARCHAR(20) NOT NULL,
    resource_url VARCHAR(1000) NOT NULL,
    description VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_resource_course (course_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程教学资源';

CREATE TABLE learning_task (
    id BIGINT NOT NULL AUTO_INCREMENT,
    course_id VARCHAR(50) NOT NULL,
    creator_id BIGINT NOT NULL,
    title VARCHAR(160) NOT NULL,
    description TEXT NULL,
    due_at DATETIME NULL,
    status TINYINT NOT NULL DEFAULT 1 COMMENT '0草稿 1开放',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_task_course (course_id, status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程学习任务';

CREATE TABLE learning_submission (
    id BIGINT NOT NULL AUTO_INCREMENT,
    task_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    content TEXT NULL,
    evidence_url VARCHAR(1000) NULL,
    status TINYINT NOT NULL DEFAULT 0 COMMENT '0待评阅 1已评阅',
    score DECIMAL(5,2) NULL,
    feedback TEXT NULL,
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_task_submission (task_id, user_id),
    KEY idx_submission_review (task_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习任务提交与评阅';

CREATE TABLE course_question (
    id BIGINT NOT NULL AUTO_INCREMENT,
    course_id VARCHAR(50) NOT NULL,
    user_id BIGINT NOT NULL,
    kind VARCHAR(20) NOT NULL DEFAULT 'QUESTION' COMMENT 'QUESTION提问 COMMENT讨论',
    title VARCHAR(160) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_question_course (course_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程评论与答疑';

CREATE TABLE course_question_reply (
    id BIGINT NOT NULL AUTO_INCREMENT,
    question_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role_type VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_question_reply (question_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程讨论回复';
