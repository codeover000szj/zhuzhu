-- 2026 content seed. Run after 20261109_learning_workflow.sql and
-- 20261110_learning_content_seed.sql. Data rows are additive and repeatable.

SET @ddl = IF(
    (SELECT COUNT(*) FROM information_schema.columns
     WHERE table_schema = DATABASE() AND table_name = 'heritage_item' AND column_name = 'cover_source_url') = 0,
    'ALTER TABLE heritage_item ADD COLUMN cover_source_url VARCHAR(1000) NULL COMMENT ''封面图片来源页面'' AFTER rights_notice',
    'SELECT 1'
);
PREPARE add_cover_source_url FROM @ddl;
EXECUTE add_cover_source_url;
DEALLOCATE PREPARE add_cover_source_url;

SET @ddl = IF(
    (SELECT COUNT(*) FROM information_schema.columns
     WHERE table_schema = DATABASE() AND table_name = 'heritage_item' AND column_name = 'cover_attribution') = 0,
    'ALTER TABLE heritage_item ADD COLUMN cover_attribution VARCHAR(500) NULL COMMENT ''封面图片署名与许可'' AFTER cover_source_url',
    'SELECT 1'
);
PREPARE add_cover_attribution FROM @ddl;
EXECUTE add_cover_attribution;
DEALLOCATE PREPARE add_cover_attribution;

-- Wikimedia Commons file pages are recorded with each cover for attribution.
INSERT INTO heritage_item (
    id, title, category, region, summary, description, status, creator_id,
    publish_time, create_time, update_time, archive_code, process_summary,
    material_list, preservation_notes, rights_notice, cover_source_url, cover_attribution
) VALUES
('HI-2026-001', '苏州评弹·开篇弹唱', '曲艺', '江苏省苏州市',
 '围绕说表、唱腔与弦索伴奏整理的曲艺数字档案。',
 '苏州评弹以说、噱、弹、唱相结合。本页记录开篇弹唱的表演结构；配图为苏州轨道交通场景中的评弹演出照片，不代表所有传统演出场景。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-001',
 '说表、唱腔、开篇结构与三弦/琵琶伴奏的衔接。',
 '评弹脚本或曲本、三弦/琵琶、演出录音与影像。',
 '数字资料卡；实物及口述档案需经传承人和馆藏方核验后补录。',
 '配图：N509FZ；CC BY-SA 4.0。转载须署名并遵循相同方式共享许可。',
 'https://commons.wikimedia.org/wiki/File:Suzhou_Pingtan_performers_at_Suzhou_Rail_Transit,_Hall_5,_MetroTrans_2024_(20240614140205).jpg',
 'Suzhou Pingtan performers at Suzhou Rail Transit, Hall 5, MetroTrans 2024 — N509FZ — CC BY-SA 4.0'),
('HI-2026-002', '端午龙舟竞渡', '民俗', '广东省佛山市顺德区容桂',
 '记录端午龙舟竞渡中的社区协作、仪式和舟体准备。',
 '龙舟竞渡是端午节俗的重要组成部分，各地仪式、舟制和竞渡规则各有差异。配图拍摄于广东顺德容桂海尾端午活动，作为地域实例，不概括其他地区习俗。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-002',
 '舟体准备、祭俗、竞渡、社区协作与节后仪式，按地方资料逐项记录。',
 '龙舟、桨、锣鼓及地方仪式用品；具体材料依地方调查核实。',
 '数字资料卡；不同地区习俗需分项建档，保存记录待社区核校。',
 '配图：Caiguanhao；CC BY-SA 3.0。转载须署名并遵循相同方式共享许可。',
 'https://commons.wikimedia.org/wiki/File:Dragon_Boat_Festival_in_Haiwei,_Ronggui,_2011.jpg',
 'Dragon Boat Festival in Haiwei, Ronggui, 2011 — Caiguanhao — CC BY-SA 3.0'),
('HI-2026-003', '苏绣·博古图镜片', '手工艺', '江苏省苏州市',
 '以苏绣藏品图像和针法资料为线索建立的刺绣档案卡。',
 '本条记录苏绣博古图镜片的图像资料，并按选稿、分丝、运针、配色等环节组织工艺字段。图片为公开馆藏图像资源，具体年代与馆藏信息以来源页面及馆方目录为准。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-003',
 '选稿、构图、分丝、运针、配色、整烫与装裱；各针法名称待传承人校核。',
 '丝线、绢/绫、绣针、绷架与图稿。',
 '图像数字复制品标示为公有领域；实物保存与修复信息待馆藏方核验。',
 '配图来源为 Wikimedia Commons，文件页标示 Public domain（公有领域）。',
 'https://commons.wikimedia.org/wiki/File:%E8%8B%8F%E7%BB%A3%E5%8D%9A%E5%8F%A4%E5%9B%BE%E9%95%9C%E7%89%87.jpg',
 '苏绣博古图镜片 — 上海博物馆馆藏图像 — Public domain'),
('HI-2026-004', '昆曲舞台表演', '戏曲', '江苏省苏州市',
 '记录昆曲表演中的曲牌、身段、舞台程式与乐队配合。',
 '昆曲以曲牌体音乐和程式化表演见长。配图为杭州大剧院昆曲演出现场，作为当代舞台实例；具体剧目、演员和场次信息以来源页面为准。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-004',
 '曲牌与唱腔、笛箫伴奏、身段、念白、舞台调度和行当程式。',
 '曲本、笛箫及锣鼓乐器、戏服与舞台道具。',
 '数字资料卡；剧目版本和演出影像授权应逐项登记。',
 '配图：Yushuo Tina；CC BY-SA 4.0。转载须署名并遵循相同方式共享许可。',
 'https://commons.wikimedia.org/wiki/File:Kunqu_opera_performance_in_Hangzhou_Grand_Theatre.jpg',
 'Kunqu opera performance in Hangzhou Grand Theatre — Yushuo Tina — CC BY-SA 4.0'),
('HI-2026-005', '苗族民间舞蹈', '舞蹈', '贵州省',
 '用于记录苗族民间舞蹈的动作、队形、服饰和节庆语境。',
 '封面为贵州苗族民间舞蹈现场照片。苗族舞蹈包含不同地域和场合的表达；该照片是相关文化背景实例，不作为某一具体舞种程式的标准复原。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-005',
 '动作节律、队形、手位、服饰和节庆场景观察；具体舞种名称需按拍摄对象核验。',
 '传统服饰、伴奏乐器、节庆场地及影像记录。',
 '配图为贵州苗族民间舞蹈现场；人物、场合和具体舞种资料待补充核验。',
 '配图：PeterSzabo83；CC BY-SA 4.0。转载须署名并遵循相同方式共享许可。',
 'https://commons.wikimedia.org/wiki/File:Miao_folkdance_-_Guizhou,_China.jpg',
 'Miao folkdance - Guizhou, China — PeterSzabo83 — CC BY-SA 4.0'),
('HI-2026-006', '兰州牛肉面制作技艺', '饮食', '甘肃省兰州市',
 '围绕和面、醒面、拉制、煮制与出餐流程建立的饮食技艺档案。',
 '配图为兰州牛肉面实物照片。档案关注面型、汤料、制作步骤及门店传承语境；具体配方和手法以相关传承人、经营者的授权资料为准。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-006',
 '和面、醒面、溜条、拉面、煮制与调汤；步骤次序和手法按师承记录。',
 '小麦粉、水、牛肉、香料、面汤及制作器具。',
 '数字资料卡；配方涉及个人或店铺经验时须经授权后记录。',
 '配图：N509FZ；CC BY-SA 4.0。转载须署名并遵循相同方式共享许可。',
 'https://commons.wikimedia.org/wiki/File:Beef_noodles_set_in_Anning,_Lanzhou_(20171005085705).jpg',
 'Beef noodles set in Anning, Lanzhou — N509FZ — CC BY-SA 4.0'),
('HI-2026-007', '中医针灸图谱', '医药', '中国',
 '以经络穴位图像和传统针灸知识资料建立的数字档案。',
 '图像为历史针灸穴位图资料，来源于 Wellcome Collection 馆藏数字资源。此档案用于非遗知识整理，不构成诊断或治疗建议。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-007',
 '经络与穴位知识、图谱版本、传承语境和历史资料出处分别登记。',
 '经络图谱、古籍、针具及经授权采集的口述资料。',
 '图像引用按 CC BY 4.0 署名；医学知识仅作文化档案，不替代临床意见。',
 '配图：Wellcome Collection；CC BY 4.0。转载须署名并链接许可说明。',
 'https://commons.wikimedia.org/wiki/File:Acupuncture_chart_with_a_series_of_points_indicated_on_the_Wellcome_L0012239.jpg',
 'Acupuncture chart with a series of points indicated — Wellcome Collection — CC BY 4.0'),
('HI-2026-008', '侗族鼓楼营造技艺', '建筑', '贵州省黔东南州黎平一带',
 '记录侗族鼓楼的木构形制、公共空间功能与营造知识。',
 '配图为肇兴鼓楼实景。鼓楼兼具议事、迎宾和节庆活动等社区功能；图片对应具体建筑，营造工序仍需结合当地匠人访谈和建筑测绘补录。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-008',
 '木构构件加工、榫卯搭建、楼层装饰、维护和社区使用场景。',
 '木材、梁柱构件、榫卯工具及传统营造图样；树种与尺寸以实测记录为准。',
 '配图为肇兴鼓楼；构件、营造年代及修缮记录需向当地管理方核验。',
 '配图：Doron；CC BY-SA 3.0。转载须署名并遵循相同方式共享许可。',
 'https://commons.wikimedia.org/wiki/File:ZhaoxingDrumTower.jpg',
 'ZhaoxingDrumTower — Doron — CC BY-SA 3.0'),
('HI-2026-009', '古琴艺术与减字谱', '音乐', '中国',
 '记录古琴形制、减字谱、指法、音色与传统演奏知识。',
 '配图为大都会艺术博物馆开放资源中的古琴图像，标示为 CC0。该图像用于器物识别示例，不代替实物鉴定与馆藏说明。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-009',
 '斫琴、定弦、减字谱识读、基础指法、演奏与口传记录。',
 '古琴、琴弦、琴桌、减字谱和经授权采集的演奏录音。',
 '配图来自大都会艺术博物馆开放资源并标示 CC0；实物档案待具体藏品信息核验。',
 '配图：The Metropolitan Museum of Art 开放资源；CC0。',
 'https://commons.wikimedia.org/wiki/File:Guqin_(%E5%8F%A4%E7%90%B4_)_MET_midp1999.93_2.jpg',
 'Guqin (MET midp1999.93) — The Metropolitan Museum of Art — CC0'),
('HI-2026-010', '苗族古歌口传文学档案', '文学', '贵州省黔东南州',
 '记录苗族古歌的口传文本、演唱场合、讲述脉络和社区校勘信息。',
 '中国非遗网项目资料将苗族古歌记述为涵盖宇宙起源、族群迁徙和日常生活的口头传统。配图为苗族乐师演奏照片，仅作文化背景图，不是某一首古歌的文本或演唱现场记录。',
 2, 1, '2026-11-09 20:00:00', '2026-11-09 20:00:00', '2026-11-09 20:00:00', 'ICH-2026-010',
 '口头叙事、演唱、记忆、传习场合、苗语文本记录与社区校勘。',
 '经传承人授权的录音、苗语文本、访谈记录和社区校勘稿。',
 '苗族古歌项目关联传承人以中国非遗网名录为准；口述、文本及影像须经社区授权。',
 '配图：Michael Mooney；CC BY 2.0。转载须署名并链接许可说明。',
 'https://commons.wikimedia.org/wiki/File:Miao_musicians.jpg',
 'Miao musicians — Michael Mooney — CC BY 2.0')
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO sys_file_info (
    original_name, file_path, file_size, file_type, business_type, business_id,
    business_field, upload_user_id, is_temp, status, create_time, expire_time
)
SELECT seed.original_name, seed.file_path, seed.file_size, 'IMG', 'HERITAGE_ITEM', seed.business_id,
       'cover', 1, 0, 1, '2026-11-09 20:00:00', NULL
FROM (
    SELECT 'cover_2026_001_suzhou_pingtan.jpg' AS original_name, '/files/bussiness/heritage_item/cover_2026_001_suzhou_pingtan.jpg' AS file_path, 3408559 AS file_size, 'HI-2026-001' AS business_id
    UNION ALL SELECT '2026_folk_dragon_boat.jpg', '/files/bussiness/heritage_item/2026_folk_dragon_boat.jpg', 565916, 'HI-2026-002'
    UNION ALL SELECT '2026_craft_suzhou_embroidery.jpg', '/files/bussiness/heritage_item/2026_craft_suzhou_embroidery.jpg', 827872, 'HI-2026-003'
    UNION ALL SELECT '2026_opera_kunqu.jpg', '/files/bussiness/heritage_item/2026_opera_kunqu.jpg', 135980, 'HI-2026-004'
    UNION ALL SELECT '2026_dance_miao_festival.jpg', '/files/bussiness/heritage_item/2026_dance_miao_festival.jpg', 508491, 'HI-2026-005'
    UNION ALL SELECT '2026_food_lanzhou_beef_noodles.jpg', '/files/bussiness/heritage_item/2026_food_lanzhou_beef_noodles.jpg', 300121, 'HI-2026-006'
    UNION ALL SELECT '2026_medicine_acupuncture_chart.jpg', '/files/bussiness/heritage_item/2026_medicine_acupuncture_chart.jpg', 1218217, 'HI-2026-007'
    UNION ALL SELECT '2026_architecture_zhaoxing_drum_tower.jpg', '/files/bussiness/heritage_item/2026_architecture_zhaoxing_drum_tower.jpg', 439770, 'HI-2026-008'
    UNION ALL SELECT '2026_music_guqin.jpg', '/files/bussiness/heritage_item/2026_music_guqin.jpg', 273750, 'HI-2026-009'
    UNION ALL SELECT '2026_literature_miao_musicians.jpg', '/files/bussiness/heritage_item/2026_literature_miao_musicians.jpg', 330489, 'HI-2026-010'
) AS seed
WHERE NOT EXISTS (
    SELECT 1 FROM sys_file_info existing
    WHERE existing.business_type = 'HERITAGE_ITEM'
      AND existing.business_id = seed.business_id
      AND existing.business_field = 'cover'
      AND existing.status = 1
);

INSERT INTO inheritor (id, name, title, region, bio, avatar_file_id, create_time, update_time)
VALUES
('INH-2026-001', '张洪珍', '苗族古歌项目代表性传承人', '贵州省黔东南州',
 '中国非遗网“苗族古歌”项目名录列载的代表性传承人。本平台当前仅登记公开名录中的姓名和项目关联，个人经历与师承资料留待授权核验后补录。来源：https://www.ihchina.cn/project_details/12178.html', NULL, '2026-11-09 20:00:00', '2026-11-09 20:00:00'),
('INH-2026-002', '田锦锋', '苗族古歌项目代表性传承人', '贵州省黔东南州',
 '中国非遗网“苗族古歌”项目名录列载的代表性传承人。本平台当前仅登记公开名录中的姓名和项目关联，个人经历与师承资料留待授权核验后补录。来源：https://www.ihchina.cn/project_details/12178.html', NULL, '2026-11-09 20:00:00', '2026-11-09 20:00:00'),
('INH-2026-003', '张定强', '苗族古歌项目代表性传承人', '贵州省黔东南州',
 '中国非遗网“苗族古歌”项目名录列载的代表性传承人。本平台当前仅登记公开名录中的姓名和项目关联，个人经历与师承资料留待授权核验后补录。来源：https://www.ihchina.cn/project_details/12178.html', NULL, '2026-11-09 20:00:00', '2026-11-09 20:00:00'),
('INH-2026-004', '刘永洪', '苗族古歌项目代表性传承人', '贵州省黔东南州',
 '中国非遗网“苗族古歌”项目名录列载的代表性传承人。本平台当前仅登记公开名录中的姓名和项目关联，个人经历与师承资料留待授权核验后补录。来源：https://www.ihchina.cn/project_details/12178.html', NULL, '2026-11-09 20:00:00', '2026-11-09 20:00:00')
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO inheritor_item (inheritor_id, item_id)
SELECT seed.inheritor_id, seed.item_id
FROM (
    SELECT 'INH-2026-001' AS inheritor_id, 'HI-2026-010' AS item_id
    UNION ALL SELECT 'INH-2026-002', 'HI-2026-010'
    UNION ALL SELECT 'INH-2026-003', 'HI-2026-010'
    UNION ALL SELECT 'INH-2026-004', 'HI-2026-010'
) AS seed
WHERE NOT EXISTS (
    SELECT 1 FROM inheritor_item existing
    WHERE existing.inheritor_id = seed.inheritor_id AND existing.item_id = seed.item_id
);

INSERT INTO activity (id, title, type, start_time, end_time, location, description, status, cover_file_id, create_time, update_time)
VALUES
('ACT-2026-001', '京津冀运河非遗交流互鉴活动', '展演', '2026-09-18 09:00:00', '2026-09-22 18:00:00', '京津冀大运河沿线，详见官方报道',
 '2026年京津冀运河非遗交流互鉴活动，具体安排以主办方报道为准。来源：https://www.ihchina.cn/news2_details/31678.html', 3, NULL, '2026-11-09 20:00:00', '2026-11-09 20:00:00'),
('ACT-2026-002', '第五届丹寨非遗周', '展演', '2026-09-20 09:00:00', '2026-09-24 18:00:00', '贵州省黔东南州丹寨县',
 '第五届丹寨非遗周活动，展演与体验项目以主办方报道为准。来源：https://www.ihchina.cn/news2_details/31675.html', 3, NULL, '2026-11-09 20:00:00', '2026-11-09 20:00:00'),
('ACT-2026-003', '南宁—东盟非遗周', '展演', '2026-09-24 09:00:00', '2026-09-28 18:00:00', '广西壮族自治区南宁市',
 '南宁—东盟非遗周交流活动，具体议程和参与项目以官方报道为准。来源：https://www.ihchina.cn/news2_details/31679.html', 3, NULL, '2026-11-09 20:00:00', '2026-11-09 20:00:00'),
('ACT-2026-004', '广东非遗精品援疆展示交流展', '展览', '2026-09-24 09:00:00', '2026-10-24 18:00:00', '新疆维吾尔自治区，详见官方报道',
 '广东非遗精品援疆展示交流展，巡展安排以主办方报道为准。来源：https://www.ihchina.cn/news2_details/31676.html', 3, NULL, '2026-11-09 20:00:00', '2026-11-09 20:00:00')
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO course_resource (course_id, creator_id, title, resource_type, resource_url, description, created_at)
SELECT seed.course_id, 2, seed.title, 'LINK', seed.resource_url, seed.description, '2026-11-09 20:00:00'
FROM (
    SELECT 'CRS-2026-001' AS course_id, '苏州评弹演出影像与来源' AS title,
           'https://commons.wikimedia.org/wiki/File:Suzhou_Pingtan_performers_at_Suzhou_Rail_Transit,_Hall_5,_MetroTrans_2024_(20240614140205).jpg' AS resource_url,
           '用于观察说表与弹唱场景；引用图片时遵循 CC BY-SA 4.0。' AS description
    UNION ALL SELECT 'CRS-2026-002', '端午龙舟活动影像与来源',
           'https://commons.wikimedia.org/wiki/File:Dragon_Boat_Festival_in_Haiwei,_Ronggui,_2011.jpg',
           '用于比较一个地方实例与课程中的节俗记录；遵循 CC BY-SA 3.0。'
    UNION ALL SELECT 'CRS-2026-003', '中国非遗项目名录检索入口',
           'https://www.ihchina.cn/project',
           '按关键词检索传统制陶相关项目，核对地域和项目名称后再引用。'
    UNION ALL SELECT 'CRS-2026-004', '昆曲舞台演出影像与来源',
           'https://commons.wikimedia.org/wiki/File:Kunqu_opera_performance_in_Hangzhou_Grand_Theatre.jpg',
           '用于观察舞台身段；图片遵循 CC BY-SA 4.0。'
    UNION ALL SELECT 'CRS-2026-005', '传统舞蹈项目名录检索入口',
           'https://www.ihchina.cn/project',
           '按课程主题查看项目名录，并将动作观察与具体地域、场合分开记录。'
    UNION ALL SELECT 'CRS-2026-006', '兰州牛肉面图像与来源',
           'https://commons.wikimedia.org/wiki/File:Beef_noodles_set_in_Anning,_Lanzhou_(20171005085705).jpg',
           '用于观察成品形态；图片遵循 CC BY-SA 4.0。'
    UNION ALL SELECT 'CRS-2026-007', '大都会艺术博物馆古琴开放图像',
           'https://commons.wikimedia.org/wiki/File:Guqin_(%E5%8F%A4%E7%90%B4_)_MET_midp1999.93_2.jpg',
           '馆藏图像标示为 CC0，可用于器物结构观察。'
) AS seed
WHERE NOT EXISTS (
    SELECT 1 FROM course_resource existing
    WHERE existing.course_id = seed.course_id AND existing.title = seed.title
);

INSERT INTO learning_task (course_id, creator_id, title, description, due_at, status, created_at)
SELECT seed.course_id, 2, seed.title, seed.description, seed.due_at, 1, '2026-11-09 20:00:00'
FROM (
    SELECT 'CRS-2026-001' AS course_id, '评弹开篇节奏标注' AS title,
           '选取一段经授权的评弹片段，标注说表停连、唱腔句读与伴奏拍点，并注明资料来源。' AS description,
           '2026-11-20 23:59:00' AS due_at
    UNION ALL SELECT 'CRS-2026-002', '家乡端午节俗观察',
           '记录一项端午节俗的时间、地点、参与者和资料来源；区分亲历观察与二手资料。',
           '2026-11-21 23:59:00'
    UNION ALL SELECT 'CRS-2026-003', '传统制陶工序观察表',
           '按材料准备、成型、修整和烧制整理观察表；图片与工艺说明需注明出处。',
           '2026-11-22 23:59:00'
    UNION ALL SELECT 'CRS-2026-004', '昆曲身段与节拍记录',
           '选取一段公开演出资料，记录手位、眼神、舞台方位与节拍的对应关系。',
           '2026-11-23 23:59:00'
    UNION ALL SELECT 'CRS-2026-005', '舞蹈动作观察笔记',
           '以连续动作图或文字记录课程片段，注明舞种、地域和资料来源；不把背景图片当作动作证据。',
           '2026-11-24 23:59:00'
    UNION ALL SELECT 'CRS-2026-006', '拉面技艺流程记录',
           '按和面、醒面、拉制和煮制步骤记录观察结果，并说明资料来自现场、课程还是公开图像。',
           '2026-11-25 23:59:00'
    UNION ALL SELECT 'CRS-2026-007', '古琴音色听辨笔记',
           '对散音、泛音和按音各记录一段练习观察，附谱面位置或经授权的音频来源。',
           '2026-11-26 23:59:00'
) AS seed
WHERE NOT EXISTS (
    SELECT 1 FROM learning_task existing
    WHERE existing.course_id = seed.course_id AND existing.title = seed.title
);

INSERT INTO course_enrollment (user_id, course_id, created_at, updated_at)
SELECT 1, c.id, '2026-11-09 20:00:00', '2026-11-09 20:00:00'
FROM course c
WHERE c.id LIKE 'CRS-2026-%'
  AND NOT EXISTS (
      SELECT 1 FROM course_enrollment existing
      WHERE existing.user_id = 1 AND existing.course_id = c.id
  );
