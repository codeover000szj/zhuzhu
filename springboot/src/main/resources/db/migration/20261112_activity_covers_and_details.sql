-- Manual, guarded activity content update; normal startup does not import this file.
-- Photos are saved under springboot/files; descriptions are based on cited public reports
-- or learning introductions for the six existing demonstration activities.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO sys_file_info (original_name,file_path,file_size,file_type,business_type,business_id,business_field,upload_user_id,is_temp,status,create_time)
SELECT '2026_canal_culture.jpg','/files/bussiness/activity/2026_canal_culture.jpg',254086,'IMG','ACTIVITY','ACT-2026-001','cover',1,0,1,NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_file_info WHERE business_type='ACTIVITY' AND business_id='ACT-2026-001' AND business_field='cover' AND status=1 AND file_path='/files/bussiness/activity/2026_canal_culture.jpg');
UPDATE activity a LEFT JOIN sys_file_info current_cover ON current_cover.id=a.cover_file_id
SET a.cover_file_id=(SELECT f.id FROM sys_file_info f WHERE f.business_type='ACTIVITY' AND f.business_id=a.id AND f.business_field='cover' AND f.status=1 AND f.file_path='/files/bussiness/activity/2026_canal_culture.jpg' ORDER BY f.id DESC LIMIT 1), a.update_time=NOW()
WHERE a.id='ACT-2026-001' AND (a.cover_file_id IS NULL OR (current_cover.business_type='ACTIVITY' AND current_cover.business_id=a.id AND current_cover.file_path='/images/verified-events/covered-bridges.jpg'));
UPDATE sys_file_info f JOIN activity a ON a.id=f.business_id SET f.status=0 WHERE f.business_type='ACTIVITY' AND f.business_field='cover' AND f.business_id='ACT-2026-001' AND f.file_path='/images/verified-events/covered-bridges.jpg' AND a.cover_file_id<>f.id;

INSERT INTO sys_file_info (original_name,file_path,file_size,file_type,business_type,business_id,business_field,upload_user_id,is_temp,status,create_time)
SELECT '2026_danzhai_miao_dance.jpg','/files/bussiness/activity/2026_danzhai_miao_dance.jpg',476765,'IMG','ACTIVITY','ACT-2026-002','cover',1,0,1,NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_file_info WHERE business_type='ACTIVITY' AND business_id='ACT-2026-002' AND business_field='cover' AND status=1 AND file_path='/files/bussiness/activity/2026_danzhai_miao_dance.jpg');
UPDATE activity a LEFT JOIN sys_file_info current_cover ON current_cover.id=a.cover_file_id
SET a.cover_file_id=(SELECT f.id FROM sys_file_info f WHERE f.business_type='ACTIVITY' AND f.business_id=a.id AND f.business_field='cover' AND f.status=1 AND f.file_path='/files/bussiness/activity/2026_danzhai_miao_dance.jpg' ORDER BY f.id DESC LIMIT 1), a.update_time=NOW()
WHERE a.id='ACT-2026-002' AND (a.cover_file_id IS NULL OR (current_cover.business_type='ACTIVITY' AND current_cover.business_id=a.id AND current_cover.file_path='/images/verified-events/nadamu-poster.svg'));
UPDATE sys_file_info f JOIN activity a ON a.id=f.business_id SET f.status=0 WHERE f.business_type='ACTIVITY' AND f.business_field='cover' AND f.business_id='ACT-2026-002' AND f.file_path='/images/verified-events/nadamu-poster.svg' AND a.cover_file_id<>f.id;

INSERT INTO sys_file_info (original_name,file_path,file_size,file_type,business_type,business_id,business_field,upload_user_id,is_temp,status,create_time)
SELECT '2026_nanning_asean_drums.jpg','/files/bussiness/activity/2026_nanning_asean_drums.jpg',124410,'IMG','ACTIVITY','ACT-2026-003','cover',1,0,1,NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_file_info WHERE business_type='ACTIVITY' AND business_id='ACT-2026-003' AND business_field='cover' AND status=1 AND file_path='/files/bussiness/activity/2026_nanning_asean_drums.jpg');
UPDATE activity a LEFT JOIN sys_file_info current_cover ON current_cover.id=a.cover_file_id
SET a.cover_file_id=(SELECT f.id FROM sys_file_info f WHERE f.business_type='ACTIVITY' AND f.business_id=a.id AND f.business_field='cover' AND f.status=1 AND f.file_path='/files/bussiness/activity/2026_nanning_asean_drums.jpg' ORDER BY f.id DESC LIMIT 1), a.update_time=NOW()
WHERE a.id='ACT-2026-003' AND (a.cover_file_id IS NULL OR (current_cover.business_type='ACTIVITY' AND current_cover.business_id=a.id AND current_cover.file_path='/images/verified-events/keyiguan.jpg'));
UPDATE sys_file_info f JOIN activity a ON a.id=f.business_id SET f.status=0 WHERE f.business_type='ACTIVITY' AND f.business_field='cover' AND f.business_id='ACT-2026-003' AND f.file_path='/images/verified-events/keyiguan.jpg' AND a.cover_file_id<>f.id;

INSERT INTO sys_file_info (original_name,file_path,file_size,file_type,business_type,business_id,business_field,upload_user_id,is_temp,status,create_time)
SELECT '2026_guangdong_craft_exchange.jpg','/files/bussiness/activity/2026_guangdong_craft_exchange.jpg',142988,'IMG','ACTIVITY','ACT-2026-004','cover',1,0,1,NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_file_info WHERE business_type='ACTIVITY' AND business_id='ACT-2026-004' AND business_field='cover' AND status=1 AND file_path='/files/bussiness/activity/2026_guangdong_craft_exchange.jpg');
UPDATE activity a LEFT JOIN sys_file_info current_cover ON current_cover.id=a.cover_file_id
SET a.cover_file_id=(SELECT f.id FROM sys_file_info f WHERE f.business_type='ACTIVITY' AND f.business_id=a.id AND f.business_field='cover' AND f.status=1 AND f.file_path='/files/bussiness/activity/2026_guangdong_craft_exchange.jpg' ORDER BY f.id DESC LIMIT 1), a.update_time=NOW()
WHERE a.id='ACT-2026-004' AND (a.cover_file_id IS NULL OR (current_cover.business_type='ACTIVITY' AND current_cover.business_id=a.id AND current_cover.file_path='/images/verified-events/qixi-workshop.jpg'));
UPDATE sys_file_info f JOIN activity a ON a.id=f.business_id SET f.status=0 WHERE f.business_type='ACTIVITY' AND f.business_field='cover' AND f.business_id='ACT-2026-004' AND f.file_path='/images/verified-events/qixi-workshop.jpg' AND a.cover_file_id<>f.id;

UPDATE activity SET description='2026年9月18日至22日，“传承运河文脉·焕新非遗华章”非物质文化遗产交流互鉴活动沿大运河展开，串联北京西城、天津和平、河北沧州和衡水四地。65项非遗项目、近100名传承人通过市集、展演、体验和座谈，共同呈现运河沿线的生活传统与工艺智慧。\n\n衡水站展示内画鼻烟壶、花茶制作和千层底布鞋等项目；沧州站在中国大运河非物质文化遗产展示馆开展武术、古琴斫制、木版水印等展示交流；天津站以古琴演奏、评书等节目收官，让公众近距离感受传统技艺。\n\n活动将项目展示与区域协作结合，推动传承人互访、场馆合作和资源共享。四地签署合作备忘录、启动跨区域非遗交流协作机制，探索常态化保护与传习。本页依据公开报道整理为活动回顾，完整内容可通过下方来源入口阅读。',update_time=NOW()
WHERE id='ACT-2026-001' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='2026年京津冀运河非遗交流互鉴活动以大运河文化带为线索，邀请沿线城市的非遗保护机构、传承人、研究者和公众共同参与。活动通过专题展演、技艺展示、传统工艺体验和保护经验交流，呈现运河沿岸的民歌、曲艺、饮食、手工艺与民俗生活。观众可以从一件器物、一段唱腔或一项节俗，了解非遗如何在水路交通、城市往来和日常生产中持续生长。活动也设置青年传承与数字记录主题，鼓励用影像、文字和档案卡片保存工艺流程与口述记忆。本站根据中国非物质文化遗产网公开报道整理活动档案，配图为运河桥梁主题视觉，用于表达活动的地域文化意象，并非本场现场摄影。具体场次、参与方式和后续安排请以主办方公告为准。公开来源：https://www.ihchina.cn/news2_details/31678.html');

UPDATE activity SET description='第五届丹寨非遗周于2026年9月20日至24日在贵州黔东南丹寨举行，以“健康中国·非遗丹寨”为主题。活动由贵州省文化和旅游厅、黔东南州人民政府主办，汇聚南北非遗精品与多民族文化，为市民游客呈现可观、可赏、可品、可参与的文化交流体验。\n\n开幕式在丹寨万达小镇锦鸡广场举行，以苗族芦笙舞锦鸡舞拉开帷幕。侗族大歌、蒙古族长调民歌、马头琴音乐、华阴老腔等轮番亮相，六个节目串联九项非遗代表性项目，并以多民族服饰秀《贵州村T》展现传统服饰的当代表达。\n\n为期五天的活动还安排非遗SHOW、活态展演、创新创作大比拼与非遗美食汇，在舞台欣赏、技艺交流和生活体验之间建立联系。非遗周通过多元形式丰富群众文化生活、推动文旅融合。本页收录活动回顾，详细报道见下方来源入口。',update_time=NOW()
WHERE id='ACT-2026-002' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='第五届丹寨非遗周在贵州黔东南丹寨县展开，以苗族、侗族等民族文化为重要内容，组织非遗展演、传统手工艺展示、文创市集和互动体验。活动把苗绣、蜡染、古法造纸、银饰锻制、芦笙歌舞等项目放入可观看、可交流、可参与的场景，让公众理解一项技艺背后的材料选择、工序经验和社区记忆。传承人通过现场演示讲解针法、染色、纹样寓意和器物使用，青年学习者则以短视频、图文档案和研学笔记记录观察结果。非遗周还关注乡村文旅与产业协同，鼓励在尊重传统规范的前提下开发适合当代生活的产品。本站依据中国非物质文化遗产网公开报道整理，封面采用地方民俗活动主题视觉，不代表具体展位或现场摄影。实际开放时间、交通和参与要求以丹寨当地官方公告为准。公开来源：https://www.ihchina.cn/news2_details/31675.html');

UPDATE activity SET description='第四届中国（南宁）—东盟非物质文化遗产周于2026年9月24日至28日在南宁市三街两巷历史文化街区举行，以“非遗中秋奇妙游”为主题。活动汇集中国与东盟多国非遗，通过启幕大秀、沉浸式市集、趣味游园、光影展览和服饰设计赛事，连接传统节日与城市生活。\n\n壮族会鼓、侗族大歌、京族独弦琴、云南目瑙纵歌与缅甸弯琴、马来西亚梅穆隆等节目同台亮相。街区市集展出壮锦、蜀绣、苏绣、苗绣、洛阳唐三彩等技艺和文创，搭配传统美食与东南亚小吃，便于观众边逛边了解手艺。\n\n活动同时设置民俗表演、抛绣球、猜灯谜和中秋主题美陈；“国潮焕新”非遗服饰精品展、传承人面对面沙龙及百鸟衣主题光影内容延伸了观展体验。本页作为活动档案保存，节目与展览详情可通过下方官方报道继续阅读。',update_time=NOW()
WHERE id='ACT-2026-003' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='南宁—东盟非遗周以广西与东盟国家之间长期的文化交往为背景，围绕传统音乐、舞蹈、节庆、织绣、饮食和手工技艺开展交流展示。活动通过舞台展演、专题论坛、项目展陈与互动工坊，让观众看到不同地区在纹样、色彩、乐器、叙事方式上的差异，也理解海上丝绸之路和边境往来如何促成技艺传播与审美互鉴。传承人和青年艺术工作者在现场分享学习路径、社区实践和当代转化经验，观众可以在对照观察中认识非遗的共同价值：它既保存地方身份，也不断吸收新的表达方式。本站根据中国非物质文化遗产网公开资讯建立档案，配图采用非遗演艺主题图片作为活动氛围视觉，并非本场活动的现场记录。具体节目单、参与方式和后续活动以主办方公告为准。公开来源：https://www.ihchina.cn/news2_details/31679.html');

UPDATE activity SET description='“珠水润天山——广东非遗精品援疆展示交流展”于2026年9月24日在喀什地区博物馆开幕，持续至10月24日。活动由广东省对口支援新疆工作前方指挥部、广东省文化和旅游厅共同主办，联动喀什本土非遗，以传统技艺搭建粤喀文化交流的桥梁。\n\n展览采用静态展览、动态展演、成果对标与互动体验相结合的形式。启动仪式呈现英歌舞、醒狮、古琴、粤曲、广东木偶戏和广东音乐等节目；展厅展示广绣、广彩、石湾陶塑、端砚、潮州木雕等岭南工艺精品，帮助观众认识材料、造型与工艺特色。\n\n佛山剪纸、石湾陶塑DIY、广彩手绘等体验，以及粤菜、粤点和潮汕工夫茶，把展陈延伸到可触、可感的生活场景。展期覆盖中秋、国庆假期，让不同地域的传统在交流中相遇。本页依据公开报道整理为活动回顾，完整内容见下方来源入口。',update_time=NOW()
WHERE id='ACT-2026-004' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='广东非遗精品援疆展示交流展以“展示、交流、共享”为主线，将广东地区具有代表性的传统工艺和民俗文化带到新疆展出。展览通过实物、图文、影像和现场讲解，介绍广彩、广绣、石湾陶塑、醒狮及其他传统技艺的材料、工序、纹样和使用场景，同时关注非遗在不同地域生活中的新表达。现场交流环节邀请传承人、文化工作者和观众讨论传统技艺的保护记录、人才培养与文创转化，让观众从一件作品看见工匠经验，也从跨地域展览理解中华优秀传统文化的共同根脉。展览还适合学校和社区开展研学，通过观察、提问和手作体验建立更具体的学习任务。本站依据中国非物质文化遗产网公开报道整理，配图为非遗手作主题视觉，不代表具体展厅现场。巡展地点、开放安排和配套活动请以主办方公告为准。公开来源：https://www.ihchina.cn/news2_details/31676.html');

UPDATE activity SET description='苏绣艺术体验课以认识丝线、绣绷与基础针法为切入点，引导学习者从一针一线理解传统刺绣的精细表达。观察绣稿时，可留意花瓣、叶片和轮廓的线条走向，比较不同色阶与留白所形成的层次，体会图案与针法之间的关系。\n\n学习过程可围绕起针、运针和收针整理笔记，重点记录针脚长短、排列密度以及换色位置。练习同一片叶子或花瓣时，可对照观察线面是否平整、过渡是否自然，再思考丝线粗细与针迹方向如何影响光泽和质感。也可将前后两次练习进行对比，具体观察细节控制是否有所进步。\n\n完成练习后，可将绣稿、局部照片和操作心得归入个人学习档案，写下最需要继续练习的问题。评价作品时，既看整体构图，也关注细节控制和耐心观察。相关参与信息以主办方公布的安排为准。',update_time=NOW()
WHERE id='ACT-2025-001' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='苏绣艺术体验课面向希望了解刺绣基础的公众，安排从选线、识绷、起针到简单纹样完成的循序练习。课程首先介绍苏绣的针法分类、丝线劈丝和配色原则，再由教师示范平针、套针和乱针在花瓣、叶片及轮廓中的不同效果。参与者可以根据模板完成一幅小型练习作品，并在过程中记录针脚方向、线面平整度和换色位置。活动强调慢工细作与耐心观察，鼓励学员在完成作品后写下材料、步骤和问题，作为个人学习档案。体验课适合零基础参与，现场工具和材料以主办方提供为准。作品完成度并非唯一评价标准，理解针法逻辑、尊重工艺节奏和愿意继续练习同样重要。具体报名、名额和注意事项请以苏绣艺术馆公告为准。');

UPDATE activity SET description='中国传统手工艺精品展以不同材料和工艺门类为观察线索，帮助参观者认识陶瓷、织绣、漆艺、木作及金工等传统技艺的表现方式。观看作品时，可从造型、色彩、纹样与使用功能出发，体会手工制作留下的独特痕迹。\n\n参观记录可以选择一件作品深入展开：先描述材料与结构，再观察连接、转折、表面处理和装饰细节，思考工序如何影响最终形态。将作品与日常器物进行比较，也有助于理解传统工艺在生活方式变化中的延续和转化。也可比较同类作品，认识不同地域风格的细微差异。\n\n学习者可用文字、草图或照片整理作品档案，并注明展示信息与观察依据，避免只作好看与否的评价。亲子与学生参观可围绕一种材料提出问题，进一步查阅相关技艺资料。具体展陈及开放安排以场馆公布信息为准。',update_time=NOW()
WHERE id='ACT-2025-002' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='中国传统手工艺精品展集中呈现陶瓷、漆器、织绣、木作、金工和民间工艺等多类作品，观众可按照材料与工艺流程观看展陈。展览通过作品、工具、局部细节和文字档案说明传统技艺如何在长期实践中形成稳定的造型语言与审美标准。部分展区设置工艺演示或互动讲解，传承人会说明选材、制坯、雕刻、髹饰、染织和装配等环节的关键经验。参观者可以选择一件作品完成观察记录，分别写下它的材料、纹样、用途、制作痕迹与当代生活中的应用可能。展览适合亲子、学生和传统工艺爱好者参观，也可作为课程中的作品档案案例。展品与活动安排可能根据场馆实际调整，开放时间和讲解场次请以西湖文化广场及主办方公告为准。');

UPDATE activity SET description='华县皮影戏专场演出以影偶造型、传统唱腔与锣鼓音乐构成独特的戏剧表达。观演时，可先留意人物头饰、服装纹样和镂空线条，观察灯光穿过皮革后的色彩变化，理解静态影偶如何在影窗上形成鲜明的角色形象。\n\n观看表演可分别关注操偶动作、唱词节奏和伴奏配合。人物的行走、转身与对话往往依靠动作幅度和音乐提示传递情绪；比较不同角色的姿态与声音，也能帮助理解故事关系，感受皮影戏将雕刻、绘画和表演融为一体的特点。也可比较文场与武场，体会叙事节奏的丰富变化。\n\n演出后可整理一段印象深刻的情节，记录角色、动作与音乐之间的联系，并画出简单的影偶结构草图。学习重点是从热闹场面进一步认识技艺协作与地方文化。具体剧目和入场安排以主办方公布信息为准。',update_time=NOW()
WHERE id='ACT-2025-003' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='华县皮影戏专场演出以传统影偶、唱腔和锣鼓音乐共同构成完整的戏剧现场。演出前可先观察皮影人物的雕刻、镂空与着色，理解透明皮革在灯光下形成轮廓和色彩的原理；演出中则关注操偶动作、唱词节奏、乐队配合以及生旦净丑等角色的区分。剧目通常以民间故事、历史传说或劝善主题为基础，既有热闹的武场，也有细腻的文场。活动安排观众在演出后了解影窗、挑杆和灯具的使用方法，帮助孩子把“看戏”转化为可描述、可记录的学习经验。皮影戏对场地、灯光和音响有一定要求，实际节目、座位与入场安排请以陕西大剧院公告为准。');

UPDATE activity SET description='潍坊传统风筝制作技艺大赛围绕扎、糊、绘、放的工艺联系展开观察，呈现风筝兼具造型艺术与结构设计的特点。认识不同类型时，可比较骨架比例、翼面形态与重心位置，理解外观装饰和飞行稳定之间的相互影响。\n\n学习记录可从竹材弹性、蒙面张力和纹样布局三个方面展开。观察骨架如何支撑曲线，接点怎样保持牢固，图案又如何顺应风筝的轮廓。比较硬翅、软翅与串类结构，有助于理解传统经验如何回应风力与空间条件。也可记录调整前后的变化，尝试解释其中的具体原因。\n\n观看放飞时，应留意提线位置、受风姿态和调整方法，并遵守现场安全要求。可将结构草图、局部照片与观察心得整理为作品档案，思考风筝与节俗、游艺及地方生活的关系。具体规则与参与安排以主办方公布信息为准。',update_time=NOW()
WHERE id='ACT-2025-004' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='潍坊传统风筝制作技艺大赛以扎、糊、绘、放四个环节为核心，参赛者既要展示风筝的结构稳定性，也要体现造型、纹样和放飞效果。比赛现场可以看到硬翅、软翅、串类和龙头蜈蚣等不同类型，选手需要根据竹条弹性、纸面张力和风力条件调整骨架比例。评审通常关注制作规范、绘画完整度、起飞稳定性与传统元素表达，观众则可以通过讲解了解风筝与地方节俗、节庆游艺之间的关系。活动设置技艺展示和公众体验区域，适合记录材料、工具、步骤及安全注意事项。具体组别、报名资格、场地和比赛规则请以潍坊世界风筝博物馆发布的信息为准。');

UPDATE activity SET description='蜀绣传承与创新技艺交流会以传统针法、纹样语言和当代应用为认识线索，引导学习者理解绣品细密而丰富的层次。观察花鸟、山水等题材时，可比较针脚方向、色彩过渡与疏密变化，体会丝线表现形态和质感的不同方式。\n\n交流学习可围绕一个局部纹样展开，记录轮廓处理、针迹衔接和绷面控制等问题。将同一题材的不同表现方式并列观察，有助于分辨工艺规范与个人表达的关系，也能理解创新设计为何需要建立在扎实的技艺认识之上。同伴间可互相交换笔记，补充观察角度。\n\n学习者可从服饰、家居或日常器物中选择应用场景，思考图案尺度、材料搭配和使用耐久性。整理笔记时，应注明观察依据，并保留疑问，避免只凭外观判断工艺高低。具体交流内容和入馆安排以主办方公布信息为准。',update_time=NOW()
WHERE id='ACT-2025-005' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='蜀绣传承与创新技艺交流会围绕传统针法、纹样表达和当代设计展开。传承人通过作品展示与现场讲解，介绍平针、滚针、打籽针等针法在花鸟、山水和人物题材中的运用，并说明丝线分股、色彩过渡和绷面控制对最终效果的影响。交流环节邀请设计师、教师和学习者讨论如何在保持工艺规范的基础上，将蜀绣应用于服饰、家居、文创和公共艺术。参与者可以选择一个局部纹样进行临摹，记录线迹方向、针脚密度和配色变化，再与原作对照总结。活动重视传承人的经验分享，也重视年轻人对传统图案的新理解。现场展示、座谈流程与入馆安排请以蜀绣博物馆公告为准。');

UPDATE activity SET description='景德镇青花瓷制作体验活动以器物与纹样的关系为认识起点，引导学习者了解坯体、青花料、釉层和烧成之间的联系。观察传统花卉、枝叶或边饰时，可留意构图位置、线条节奏与留白比例，理解图案如何适应器面的弧度。\n\n学习记录可围绕勾线与分水展开，比较笔尖、笔腹和用水变化留下的不同效果。练习时宜关注起笔、行笔、收笔的连贯，以及浓淡区域的衔接。纸上练习与坯体绘画的吸水条件不同，观察结果需要结合材料与工序理解。可再比较同类纹样，归纳构图的共同规律。\n\n完成观察后，可用草图、照片和文字整理纹样设计思路，记录遇到的问题及后续调整方向。青花的最终呈色受多种烧成条件影响，涉及颜料、工具或窑炉的实践应遵循专业指导。具体参与与作品处理安排以主办方公布信息为准。',update_time=NOW()
WHERE id='ACT-2025-006' AND (description IS NULL OR CHAR_LENGTH(TRIM(description))<150 OR description='景德镇青花瓷制作体验活动以一件小型陶瓷作品为学习载体，带领参与者了解拉坯或修坯、施釉、勾线、分水和烧成之间的关系。教师会先介绍青花料的浓淡变化和毛笔控制，再示范传统花卉、枝叶或几何边饰的构图方法。参与者可在坯体或练习纸上完成纹样设计，观察笔触、用水和器面弧度对图案的影响，并把作品编号、材料和操作步骤写入活动记录。青花瓷的最终色泽还受釉料、窑温和烧成条件影响，体验现场完成的作品需等待后续烧制或领取通知。活动适合初学者，涉及工具、颜料和窑炉的环节须遵循教师指导。具体名额、费用和取件安排请以陶瓷文化创意园公告为准。');

COMMIT;
SELECT a.id,a.title,CHAR_LENGTH(a.description) AS description_length,a.cover_file_id,f.file_path FROM activity a LEFT JOIN sys_file_info f ON f.id=a.cover_file_id ORDER BY a.id;
