-- Additive demo content for the 2026 learning center and community forum.
-- Safe to run repeatedly: course IDs, chapter titles, and discussion titles are checked.

INSERT INTO course (id, title, level, description, status, cover_file_id, teacher_id, create_time, update_time)
SELECT 'CRS-2026-001', '苏州评弹：开篇、说表与弹唱', 'beginner',
       '从说表节奏、开篇结构和弹唱配合入门，配合听辨与复述练习，认识苏州评弹的表演特点。',
       1, NULL, NULL, '2026-11-09 09:00:00', '2026-11-09 09:00:00'
WHERE NOT EXISTS (SELECT 1 FROM course WHERE id = 'CRS-2026-001');

INSERT INTO course (id, title, level, description, status, cover_file_id, teacher_id, create_time, update_time)
SELECT 'CRS-2026-002', '端午节民俗：节令仪式与龙舟文化', 'beginner',
       '梳理端午节的节令记忆、地域习俗与龙舟竞渡，完成一份带来源的节俗观察记录。',
       1, NULL, NULL, '2026-11-09 09:00:00', '2026-11-09 09:00:00'
WHERE NOT EXISTS (SELECT 1 FROM course WHERE id = 'CRS-2026-002');

INSERT INTO course (id, title, level, description, status, cover_file_id, teacher_id, create_time, update_time)
SELECT 'CRS-2026-003', '宜兴紫砂陶：泥料、成型与烧制', 'intermediate',
       '认识紫砂泥料与工具，了解拍打成型、明针修整和烧制环节，并通过图例辨识器型。',
       1, NULL, NULL, '2026-11-09 09:00:00', '2026-11-09 09:00:00'
WHERE NOT EXISTS (SELECT 1 FROM course WHERE id = 'CRS-2026-003');

INSERT INTO course (id, title, level, description, status, cover_file_id, teacher_id, create_time, update_time)
SELECT 'CRS-2026-004', '昆曲入门：身段、水袖与舞台节奏', 'beginner',
       '通过身段、眼神、水袖与锣鼓点的基础练习，理解昆曲表演中程式与人物表达的关系。',
       1, NULL, NULL, '2026-11-09 09:00:00', '2026-11-09 09:00:00'
WHERE NOT EXISTS (SELECT 1 FROM course WHERE id = 'CRS-2026-004');

INSERT INTO course (id, title, level, description, status, cover_file_id, teacher_id, create_time, update_time)
SELECT 'CRS-2026-005', '传统舞蹈观察：孔雀舞的形态与节奏', 'beginner',
       '以影像观察、动作记录和节奏标注为主，学习如何描述舞蹈动作及其文化语境。',
       1, NULL, NULL, '2026-11-09 09:00:00', '2026-11-09 09:00:00'
WHERE NOT EXISTS (SELECT 1 FROM course WHERE id = 'CRS-2026-005');

INSERT INTO course (id, title, level, description, status, cover_file_id, teacher_id, create_time, update_time)
SELECT 'CRS-2026-006', '兰州牛肉面：拉面技法与饮食文化', 'beginner',
       '了解和面、醒面、拉制与出餐流程，记录面型变化并认识兰州牛肉面的饮食文化。',
       1, NULL, NULL, '2026-11-09 09:00:00', '2026-11-09 09:00:00'
WHERE NOT EXISTS (SELECT 1 FROM course WHERE id = 'CRS-2026-006');

INSERT INTO course (id, title, level, description, status, cover_file_id, teacher_id, create_time, update_time)
SELECT 'CRS-2026-007', '古琴入门：识谱、指法与基础曲目', 'beginner',
       '从减字谱结构和基础指法入手，练习节拍、音色与简短乐句的记录和复盘。',
       1, NULL, NULL, '2026-11-09 09:00:00', '2026-11-09 09:00:00'
WHERE NOT EXISTS (SELECT 1 FROM course WHERE id = 'CRS-2026-007');

INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-001', '第一章：评弹的说唱结构', '认识说表、弹唱和篇章的基本结构，记录一段示范中的停连与重音。', 1
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-001' AND title = '第一章：评弹的说唱结构');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-001', '第二章：开篇节奏与气口', '拆分开篇中的句读和气口，完成慢速复述与节奏标记练习。', 2
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-001' AND title = '第二章：开篇节奏与气口');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-001', '第三章：弹唱配合练习', '观察三弦伴奏与演唱的衔接，整理一页听辨笔记并提交练习片段。', 3
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-001' AND title = '第三章：弹唱配合练习');

INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-002', '第一章：端午节的节令记忆', '从节气与地方生活出发，建立端午节相关习俗的观察清单。', 1
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-002' AND title = '第一章：端午节的节令记忆');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-002', '第二章：龙舟竞渡与社区协作', '记录龙舟竞渡的准备、队伍协作和仪式环节，区分不同地区的表达。', 2
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-002' AND title = '第二章：龙舟竞渡与社区协作');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-002', '第三章：节俗档案整理', '用时间、地点、参与者和资料出处整理一条端午节俗记录。', 3
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-002' AND title = '第三章：节俗档案整理');

INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-003', '第一章：紫砂泥料与工具', '认识常见紫砂泥料、制作工具和工作台准备，完成材料观察表。', 1
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-003' AND title = '第一章：紫砂泥料与工具');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-003', '第二章：拍打成型与器型观察', '了解泥片成型的基础步骤，通过器型图观察比例与转折。', 2
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-003' AND title = '第二章：拍打成型与器型观察');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-003', '第三章：明针修整与烧制记录', '认识表面修整和烧制环节，按工序整理一份过程记录。', 3
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-003' AND title = '第三章：明针修整与烧制记录');

INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-004', '第一章：昆曲舞台与角色行当', '了解昆曲舞台空间、角色行当和程式化表演的基本概念。', 1
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-004' AND title = '第一章：昆曲舞台与角色行当');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-004', '第二章：身段与眼神练习', '从重心、手位和眼神方向入门，完成一组慢速身段观察。', 2
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-004' AND title = '第二章：身段与眼神练习');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-004', '第三章：水袖与音乐节奏', '学习水袖动作的起落与收放，结合锣鼓点标出动作节拍。', 3
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-004' AND title = '第三章：水袖与音乐节奏');

INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-005', '第一章：动作观察与记录', '通过示范影像练习动作分解、方向标注和节奏记录。', 1
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-005' AND title = '第一章：动作观察与记录');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-005', '第二章：手位、步态与造型', '比较手位和步态的变化，绘制连续动作的简图。', 2
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-005' AND title = '第二章：手位、步态与造型');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-005', '第三章：舞蹈语境与资料引用', '结合公开资料记录舞蹈的地域、场合和表演语境，注明出处。', 3
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-005' AND title = '第三章：舞蹈语境与资料引用');

INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-006', '第一章：和面、醒面与面团状态', '认识面团准备流程，记录水量、醒面时间和面团状态的变化。', 1
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-006' AND title = '第一章：和面、醒面与面团状态');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-006', '第二章：拉制动作与面型观察', '从动作顺序观察拉制过程，对比常见面型并整理图文笔记。', 2
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-006' AND title = '第二章：拉制动作与面型观察');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-006', '第三章：一碗面的文化档案', '围绕制作流程、食用场景和地方记忆完成一条饮食文化档案。', 3
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-006' AND title = '第三章：一碗面的文化档案');

INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-007', '第一章：古琴与减字谱', '认识古琴的基本结构和减字谱记录方式，练习辨读简单指法符号。', 1
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-007' AND title = '第一章：古琴与减字谱');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-007', '第二章：基础指法与音色', '认识常见基础指法，比较散音、泛音和按音的听感差异。', 2
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-007' AND title = '第二章：基础指法与音色');
INSERT INTO course_chapter (course_id, title, content, sort)
SELECT 'CRS-2026-007', '第三章：短句练习与复盘', '完成短乐句的慢速练习，记录节拍、音色和需要复习的指法。', 3
WHERE NOT EXISTS (SELECT 1 FROM course_chapter WHERE course_id = 'CRS-2026-007' AND title = '第三章：短句练习与复盘');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-001', 1, 'QUESTION', '苏州评弹的开篇节奏怎么练稳？',
       '我在听辨练习里容易把说表的停连和伴奏节拍混在一起。大家会先慢速划分句读，还是先跟伴奏打拍子？',
       '2026-11-03 09:10:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '苏州评弹的开篇节奏怎么练稳？');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-004', 1, 'QUESTION', '练水袖时怎样避免动作松散？',
       '我把水袖动作拆成起、行、收三步练习，收势时总会拖拍。想请教大家如何把动作和锣鼓点对应起来。',
       '2026-11-03 14:25:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '练水袖时怎样避免动作松散？');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-002', 1, 'COMMENT', '端午香囊的地域纹样观察',
       '我整理了几种公开资料中的香囊纹样，发现寓意和配色会随地区变化。大家做节俗档案时，会怎样记录图案来源？',
       '2026-11-04 10:00:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '端午香囊的地域纹样观察');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-003', 1, 'QUESTION', '紫砂壶明针修整的力度怎么把握？',
       '课程里提到明针会影响器表质感。我目前先对照步骤图做标注，想知道练习记录里还需要观察哪些变化。',
       '2026-11-04 16:40:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '紫砂壶明针修整的力度怎么把握？');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-005', 1, 'QUESTION', '孔雀舞动作如何做连续记录？',
       '我想把一段示范动作做成连续图示。大家更习惯按手位、步态分栏，还是按动作发生的顺序记录？',
       '2026-11-05 11:15:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '孔雀舞动作如何做连续记录？');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-006', 1, 'COMMENT', '练习记录：面型与拉制次数',
       '今天把课程示范里的动作顺序记成了表格，下一次准备对照视频记录每一步后的面团状态，看看哪些环节最影响面型。',
       '2026-11-05 18:20:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '练习记录：面型与拉制次数');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-003', 1, 'QUESTION', '泥料观察表适合记录哪些信息？',
       '我准备给不同泥料做一张观察表，目前列了颜色、颗粒感和工序。有没有适合初学者补充的观察项？',
       '2026-11-06 09:35:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '泥料观察表适合记录哪些信息？');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-007', 1, 'QUESTION', '散音、泛音和按音怎样快速区分？',
       '我在听辨笔记里给三种音色分别记了触弦方式，但回放时还是会混淆。有没有适合初学者的对照练习？',
       '2026-11-06 15:50:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '散音、泛音和按音怎样快速区分？');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-004', 1, 'COMMENT', '从人物关系理解昆曲身段',
       '对照人物关系再看同一段身段，会更容易理解动作的指向。接下来想把身段、眼神和舞台方位放在一张图里整理。',
       '2026-11-07 13:05:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '从人物关系理解昆曲身段');

INSERT INTO course_question (course_id, user_id, kind, title, content, created_at)
SELECT 'CRS-2026-007', 1, 'QUESTION', '减字谱练习怎样做错音复盘？',
       '我打算把每次练习中停顿或弹错的位置做标记，想请教怎样把谱面位置和手指动作一起记录得更清楚。',
       '2026-11-08 09:20:00'
WHERE NOT EXISTS (SELECT 1 FROM course_question WHERE title = '减字谱练习怎样做错音复盘？');

INSERT INTO course_question_reply (question_id, user_id, role_type, content, created_at)
SELECT q.id, 2, 'ADMIN', '建议先把说表文本按语意划分短句，再单独标出停连与伴奏拍点。慢速复述熟悉后，再合入伴奏。',
       '2026-11-03 10:05:00'
FROM course_question q
WHERE q.title = '苏州评弹的开篇节奏怎么练稳？'
  AND NOT EXISTS (SELECT 1 FROM course_question_reply r WHERE r.question_id = q.id);

INSERT INTO course_question_reply (question_id, user_id, role_type, content, created_at)
SELECT q.id, 2, 'ADMIN', '可先固定动作收势的位置，再用慢速节拍练完整个动作。记录每次收势和锣鼓点的对应关系，熟悉后逐步恢复原速。',
       '2026-11-03 15:10:00'
FROM course_question q
WHERE q.title = '练水袖时怎样避免动作松散？'
  AND NOT EXISTS (SELECT 1 FROM course_question_reply r WHERE r.question_id = q.id);

INSERT INTO course_question_reply (question_id, user_id, role_type, content, created_at)
SELECT q.id, 2, 'ADMIN', '建议同时保留图案照片、采集地点、使用场合和资料出处。不同地区的纹样可以并列归档，避免把一种解释写成通用结论。',
       '2026-11-04 11:20:00'
FROM course_question q
WHERE q.title = '端午香囊的地域纹样观察'
  AND NOT EXISTS (SELECT 1 FROM course_question_reply r WHERE r.question_id = q.id);

INSERT INTO course_question_reply (question_id, user_id, role_type, content, created_at)
SELECT q.id, 2, 'ADMIN', '初学时可先用课程步骤图逐段对照，记录器表变化和工具角度。涉及实际器物操作时，请以授课教师的现场示范为准。',
       '2026-11-04 17:15:00'
FROM course_question q
WHERE q.title = '紫砂壶明针修整的力度怎么把握？'
  AND NOT EXISTS (SELECT 1 FROM course_question_reply r WHERE r.question_id = q.id);

INSERT INTO course_question_reply (question_id, user_id, role_type, content, created_at)
SELECT q.id, 2, 'ADMIN', '按动作发生顺序记录通常更便于复盘，也可以在旁边补上手位、方向和节拍。图示请注明所依据的示范资料。',
       '2026-11-05 12:00:00'
FROM course_question q
WHERE q.title = '孔雀舞动作如何做连续记录？'
  AND NOT EXISTS (SELECT 1 FROM course_question_reply r WHERE r.question_id = q.id);

INSERT INTO course_question_reply (question_id, user_id, role_type, content, created_at)
SELECT q.id, 2, 'ADMIN', '可以按动作前后顺序记录揉、醒、拉等观察点，并注明示范来源和拍摄时间。这样更方便对比不同面型的过程差异。',
       '2026-11-05 19:05:00'
FROM course_question q
WHERE q.title = '练习记录：面型与拉制次数'
  AND NOT EXISTS (SELECT 1 FROM course_question_reply r WHERE r.question_id = q.id);

INSERT INTO course_question_reply (question_id, user_id, role_type, content, created_at)
SELECT q.id, 2, 'ADMIN', '可以先记录课程材料中实际出现的观察项，例如颜色、颗粒状态、可塑性和工序阶段，并把资料来源一并写在表头。',
       '2026-11-06 10:10:00'
FROM course_question q
WHERE q.title = '泥料观察表适合记录哪些信息？'
  AND NOT EXISTS (SELECT 1 FROM course_question_reply r WHERE r.question_id = q.id);

INSERT INTO course_question_reply (question_id, user_id, role_type, content, created_at)
SELECT q.id, 2, 'ADMIN', '可先听课程中的单音示范，再对照触弦方式和减字谱标记逐项记录。每次只比较两种音色，熟悉后再做混合听辨。',
       '2026-11-06 16:25:00'
FROM course_question q
WHERE q.title = '散音、泛音和按音怎样快速区分？'
  AND NOT EXISTS (SELECT 1 FROM course_question_reply r WHERE r.question_id = q.id);

INSERT INTO course_question_reply (question_id, user_id, role_type, content, created_at)
SELECT q.id, 2, 'ADMIN', '这个整理方法很实用。建议给舞台方位、人物关系和身段动作使用不同标记，并在图注里写明所参考的课程片段。',
       '2026-11-07 14:00:00'
FROM course_question q
WHERE q.title = '从人物关系理解昆曲身段'
  AND NOT EXISTS (SELECT 1 FROM course_question_reply r WHERE r.question_id = q.id);
