-- Enrich the activity records that previously rendered a placeholder cover or empty detail.
-- The four public 2026 records use existing, locally served theme images from verified-events.
START TRANSACTION;

INSERT INTO sys_file_info
    (original_name, file_path, file_size, file_type, business_type, business_id,
     business_field, upload_user_id, is_temp, status, create_time)
SELECT 'covered-bridges.jpg', '/images/verified-events/covered-bridges.jpg', 256661,
       'IMG', 'ACTIVITY', 'ACT-2026-001', 'cover', 1, 0, 1, NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM sys_file_info
    WHERE business_type = 'ACTIVITY' AND business_id = 'ACT-2026-001'
      AND business_field = 'cover' AND file_path = '/images/verified-events/covered-bridges.jpg'
);
INSERT INTO sys_file_info
    (original_name, file_path, file_size, file_type, business_type, business_id,
     business_field, upload_user_id, is_temp, status, create_time)
SELECT 'nadamu-poster.svg', '/images/verified-events/nadamu-poster.svg', 1378,
       'IMG', 'ACTIVITY', 'ACT-2026-002', 'cover', 1, 0, 1, NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM sys_file_info
    WHERE business_type = 'ACTIVITY' AND business_id = 'ACT-2026-002'
      AND business_field = 'cover' AND file_path = '/images/verified-events/nadamu-poster.svg'
);
INSERT INTO sys_file_info
    (original_name, file_path, file_size, file_type, business_type, business_id,
     business_field, upload_user_id, is_temp, status, create_time)
SELECT 'keyiguan.jpg', '/images/verified-events/keyiguan.jpg', 131738,
       'IMG', 'ACTIVITY', 'ACT-2026-003', 'cover', 1, 0, 1, NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM sys_file_info
    WHERE business_type = 'ACTIVITY' AND business_id = 'ACT-2026-003'
      AND business_field = 'cover' AND file_path = '/images/verified-events/keyiguan.jpg'
);
INSERT INTO sys_file_info
    (original_name, file_path, file_size, file_type, business_type, business_id,
     business_field, upload_user_id, is_temp, status, create_time)
SELECT 'qixi-workshop.jpg', '/images/verified-events/qixi-workshop.jpg', 143351,
       'IMG', 'ACTIVITY', 'ACT-2026-004', 'cover', 1, 0, 1, NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM sys_file_info
    WHERE business_type = 'ACTIVITY' AND business_id = 'ACT-2026-004'
      AND business_field = 'cover' AND file_path = '/images/verified-events/qixi-workshop.jpg'
);

UPDATE activity a
SET cover_file_id = (
    SELECT f.id FROM sys_file_info f
    WHERE f.business_type = 'ACTIVITY' AND f.business_id = a.id
      AND f.business_field = 'cover' AND f.status = 1
    ORDER BY f.id DESC LIMIT 1
)
WHERE a.id IN ('ACT-2026-001','ACT-2026-002','ACT-2026-003','ACT-2026-004')
  AND a.cover_file_id IS NULL;

UPDATE activity SET description = '2026年京津冀运河非遗交流互鉴活动以大运河文化带为线索，邀请沿线城市的非遗保护机构、传承人、研究者和公众共同参与。活动通过专题展演、技艺展示、传统工艺体验和保护经验交流，呈现运河沿岸的民歌、曲艺、饮食、手工艺与民俗生活。观众可以从一件器物、一段唱腔或一项节俗，了解非遗如何在水路交通、城市往来和日常生产中持续生长。活动也设置青年传承与数字记录主题，鼓励用影像、文字和档案卡片保存工艺流程与口述记忆。本站根据中国非物质文化遗产网公开报道整理活动档案，配图为运河桥梁主题视觉，用于表达活动的地域文化意象，并非本场现场摄影。具体场次、参与方式和后续安排请以主办方公告为准。公开来源：https://www.ihchina.cn/news2_details/31678.html'
WHERE id = 'ACT-2026-001' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) < 150);

UPDATE activity SET description = '第五届丹寨非遗周在贵州黔东南丹寨县展开，以苗族、侗族等民族文化为重要内容，组织非遗展演、传统手工艺展示、文创市集和互动体验。活动把苗绣、蜡染、古法造纸、银饰锻制、芦笙歌舞等项目放入可观看、可交流、可参与的场景，让公众理解一项技艺背后的材料选择、工序经验和社区记忆。传承人通过现场演示讲解针法、染色、纹样寓意和器物使用，青年学习者则以短视频、图文档案和研学笔记记录观察结果。非遗周还关注乡村文旅与产业协同，鼓励在尊重传统规范的前提下开发适合当代生活的产品。本站依据中国非物质文化遗产网公开报道整理，封面采用地方民俗活动主题视觉，不代表具体展位或现场摄影。实际开放时间、交通和参与要求以丹寨当地官方公告为准。公开来源：https://www.ihchina.cn/news2_details/31675.html'
WHERE id = 'ACT-2026-002' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) < 150);

UPDATE activity SET description = '南宁—东盟非遗周以广西与东盟国家之间长期的文化交往为背景，围绕传统音乐、舞蹈、节庆、织绣、饮食和手工技艺开展交流展示。活动通过舞台展演、专题论坛、项目展陈与互动工坊，让观众看到不同地区在纹样、色彩、乐器、叙事方式上的差异，也理解海上丝绸之路和边境往来如何促成技艺传播与审美互鉴。传承人和青年艺术工作者在现场分享学习路径、社区实践和当代转化经验，观众可以在对照观察中认识非遗的共同价值：它既保存地方身份，也不断吸收新的表达方式。本站根据中国非物质文化遗产网公开资讯建立档案，配图采用非遗演艺主题图片作为活动氛围视觉，并非本场活动的现场记录。具体节目单、参与方式和后续活动以主办方公告为准。公开来源：https://www.ihchina.cn/news2_details/31679.html'
WHERE id = 'ACT-2026-003' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) < 150);

UPDATE activity SET description = '广东非遗精品援疆展示交流展以“展示、交流、共享”为主线，将广东地区具有代表性的传统工艺和民俗文化带到新疆展出。展览通过实物、图文、影像和现场讲解，介绍广彩、广绣、石湾陶塑、醒狮及其他传统技艺的材料、工序、纹样和使用场景，同时关注非遗在不同地域生活中的新表达。现场交流环节邀请传承人、文化工作者和观众讨论传统技艺的保护记录、人才培养与文创转化，让观众从一件作品看见工匠经验，也从跨地域展览理解中华优秀传统文化的共同根脉。展览还适合学校和社区开展研学，通过观察、提问和手作体验建立更具体的学习任务。本站依据中国非物质文化遗产网公开报道整理，配图为非遗手作主题视觉，不代表具体展厅现场。巡展地点、开放安排和配套活动请以主办方公告为准。公开来源：https://www.ihchina.cn/news2_details/31676.html'
WHERE id = 'ACT-2026-004' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) < 150);

UPDATE activity SET description = '苏绣艺术体验课面向希望了解刺绣基础的公众，安排从选线、识绷、起针到简单纹样完成的循序练习。课程首先介绍苏绣的针法分类、丝线劈丝和配色原则，再由教师示范平针、套针和乱针在花瓣、叶片及轮廓中的不同效果。参与者可以根据模板完成一幅小型练习作品，并在过程中记录针脚方向、线面平整度和换色位置。活动强调慢工细作与耐心观察，鼓励学员在完成作品后写下材料、步骤和问题，作为个人学习档案。体验课适合零基础参与，现场工具和材料以主办方提供为准。作品完成度并非唯一评价标准，理解针法逻辑、尊重工艺节奏和愿意继续练习同样重要。具体报名、名额和注意事项请以苏绣艺术馆公告为准。'
WHERE id = 'ACT-2025-001' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) = 0);

UPDATE activity SET description = '中国传统手工艺精品展集中呈现陶瓷、漆器、织绣、木作、金工和民间工艺等多类作品，观众可按照材料与工艺流程观看展陈。展览通过作品、工具、局部细节和文字档案说明传统技艺如何在长期实践中形成稳定的造型语言与审美标准。部分展区设置工艺演示或互动讲解，传承人会说明选材、制坯、雕刻、髹饰、染织和装配等环节的关键经验。参观者可以选择一件作品完成观察记录，分别写下它的材料、纹样、用途、制作痕迹与当代生活中的应用可能。展览适合亲子、学生和传统工艺爱好者参观，也可作为课程中的作品档案案例。展品与活动安排可能根据场馆实际调整，开放时间和讲解场次请以西湖文化广场及主办方公告为准。'
WHERE id = 'ACT-2025-002' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) = 0);

UPDATE activity SET description = '华县皮影戏专场演出以传统影偶、唱腔和锣鼓音乐共同构成完整的戏剧现场。演出前可先观察皮影人物的雕刻、镂空与着色，理解透明皮革在灯光下形成轮廓和色彩的原理；演出中则关注操偶动作、唱词节奏、乐队配合以及生旦净丑等角色的区分。剧目通常以民间故事、历史传说或劝善主题为基础，既有热闹的武场，也有细腻的文场。活动安排观众在演出后了解影窗、挑杆和灯具的使用方法，帮助孩子把“看戏”转化为可描述、可记录的学习经验。皮影戏对场地、灯光和音响有一定要求，实际节目、座位与入场安排请以陕西大剧院公告为准。'
WHERE id = 'ACT-2025-003' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) = 0);

UPDATE activity SET description = '潍坊传统风筝制作技艺大赛以扎、糊、绘、放四个环节为核心，参赛者既要展示风筝的结构稳定性，也要体现造型、纹样和放飞效果。比赛现场可以看到硬翅、软翅、串类和龙头蜈蚣等不同类型，选手需要根据竹条弹性、纸面张力和风力条件调整骨架比例。评审通常关注制作规范、绘画完整度、起飞稳定性与传统元素表达，观众则可以通过讲解了解风筝与地方节俗、节庆游艺之间的关系。活动设置技艺展示和公众体验区域，适合记录材料、工具、步骤及安全注意事项。具体组别、报名资格、场地和比赛规则请以潍坊世界风筝博物馆发布的信息为准。'
WHERE id = 'ACT-2025-004' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) = 0);

UPDATE activity SET description = '蜀绣传承与创新技艺交流会围绕传统针法、纹样表达和当代设计展开。传承人通过作品展示与现场讲解，介绍平针、滚针、打籽针等针法在花鸟、山水和人物题材中的运用，并说明丝线分股、色彩过渡和绷面控制对最终效果的影响。交流环节邀请设计师、教师和学习者讨论如何在保持工艺规范的基础上，将蜀绣应用于服饰、家居、文创和公共艺术。参与者可以选择一个局部纹样进行临摹，记录线迹方向、针脚密度和配色变化，再与原作对照总结。活动重视传承人的经验分享，也重视年轻人对传统图案的新理解。现场展示、座谈流程与入馆安排请以蜀绣博物馆公告为准。'
WHERE id = 'ACT-2025-005' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) = 0);

UPDATE activity SET description = '景德镇青花瓷制作体验活动以一件小型陶瓷作品为学习载体，带领参与者了解拉坯或修坯、施釉、勾线、分水和烧成之间的关系。教师会先介绍青花料的浓淡变化和毛笔控制，再示范传统花卉、枝叶或几何边饰的构图方法。参与者可在坯体或练习纸上完成纹样设计，观察笔触、用水和器面弧度对图案的影响，并把作品编号、材料和操作步骤写入活动记录。青花瓷的最终色泽还受釉料、窑温和烧成条件影响，体验现场完成的作品需等待后续烧制或领取通知。活动适合初学者，涉及工具、颜料和窑炉的环节须遵循教师指导。具体名额、费用和取件安排请以陶瓷文化创意园公告为准。'
WHERE id = 'ACT-2025-006' AND (description IS NULL OR CHAR_LENGTH(TRIM(description)) = 0);

COMMIT;

SELECT id, cover_file_id, CHAR_LENGTH(description) AS description_length
FROM activity
WHERE id IN ('ACT-2026-001','ACT-2026-002','ACT-2026-003','ACT-2026-004',
             'ACT-2025-001','ACT-2025-002','ACT-2025-003','ACT-2025-004',
             'ACT-2025-005','ACT-2025-006');
