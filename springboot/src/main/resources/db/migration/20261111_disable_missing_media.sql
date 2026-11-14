-- Manual, guarded repair after the live backup. No physical files are removed.
START TRANSACTION;
UPDATE user SET avatar = NULL
WHERE id = 4 AND avatar = '/files/bussiness/user_avatar/1759645666149.jpg';
UPDATE sys_file_info SET status = 0
WHERE id = 19 AND business_type = 'USER_AVATAR' AND business_id = '4'
  AND file_path = '/files/bussiness/user_avatar/1759645666149.jpg';
UPDATE sys_file_info SET status = 0
WHERE id = 24 AND business_type = 'COURSE_CHAPTER' AND business_id = '29'
  AND file_path = '/files/bussiness/course_chapter/1760428168517.mp4';
UPDATE course_chapter
SET title = '学习回顾与青花纹样自评',
    content = '本章通过作品回顾巩固青花瓷绘画的基本步骤。先选取本课程已经练习过的花卉、枝叶或几何边饰，在纸上画出小稿，明确主体、辅助纹样和留白的关系。观察图案是否适合器物表面的弧度，避免把平面画稿直接生硬地搬到瓶身或杯壁。初学者可以先练习局部纹样，熟悉笔尖、笔腹与笔根留下的不同痕迹，再尝试连续的完整构图。\n\n练习时重点记录线条和层次。勾线应注意起笔、行笔和收笔的连贯，转折处保持节奏，不必反复描粗同一条轮廓。分水与填色练习应比较不同用水量、料色浓淡和落笔顺序产生的变化，观察深浅区域是否自然衔接。每次改变一个条件，便于判断原因；在纸上模拟的效果只能帮助理解笔法，实际坯体吸水性和烧成结果仍需在正规教学条件下验证。\n\n完成后从构图、线条、浓淡和整洁度四方面自评。检查主体是否清楚，纹样间距是否均衡，留白是否通透，线条是否有明显断裂或堆叠。为作品拍摄正面与细节照片，记录练习日期、所用工具、遇到的问题以及下一次准备调整的方法。将同一纹样的前后两次练习并列比较，比只评价好看与否更容易发现进步。\n\n本章学习任务是提交一张构图小稿、一组笔法练习和一段自评说明。可在共学答疑中附上局部照片，说明具体困惑，例如叶片层次不足、边饰衔接不齐或器面布局拥挤。交流时描述操作步骤与观察结果，便于同学和教师给出有针对性的建议。涉及陶瓷颜料、坯体加工与窑炉的实践，应在具备条件的教学场所完成，并遵循教师指导与材料使用规范。'
WHERE id = 29 AND course_id = 'CRS-2025-006' AND title = '测试' AND content = '111';
COMMIT;

SELECT id, status FROM sys_file_info WHERE id IN (19, 24);
SELECT id, title, CHAR_LENGTH(content) AS content_length FROM course_chapter WHERE id = 29;
