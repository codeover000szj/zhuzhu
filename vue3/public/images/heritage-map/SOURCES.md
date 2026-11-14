# 首页非遗地图素材与数据

核验日期：2026-11-10。

- 参考页面：https://www.ihchina.cn/#page5 （中国非物质文化遗产网·中国非物质文化遗产数字博物馆）
- `china-map.png` 原图：https://www.ihchina.cn/Public/static/themes/image/temp/png77.png 。原图 891×641，未经裁切，保留台湾省、海南省、南海诸岛附图；页面按原站显示审图号 GS（2019）3443号。
- `carving-background.jpg`：https://www.ihchina.cn/Uploads/Picture/2019/10/11/s5da048b1840e2.jpg （原站同款木刻背景，1920×960）
- `title-ornament.png`：https://www.ihchina.cn/Public/static/themes/image/temp/png8.png
- `total-ornament.png`：https://www.ihchina.cn/Public/static/themes/image/temp/png10.png
- 全国统计直接整理自上述参考页面；34个省级行政区的国家级代表性项目及代表性传承人分门类统计，整理自公开接口 https://www.ihchina.cn/Site/Index/get_map_html.html （参数 province=行政区代码，act=p；返回中含两个统计类型）。数据保存于 `src/config/heritageMapData.json`。
- 官方统计真实截止日期为 **2025-03-13**，在页面明确保留。2026-11-10 是本项目核验日期，不能将其当作官方统计截止日。台湾省暂无统计数据；省级总数按源站各类别相加。全国汇总涵盖源站全国统计，地区之和不应自行解释为全国总数。
- 数字方块链接到中国非遗网相应门类/地区名录。底部“作品档案”链接进入本站，不把本站资料数量混作官方总量。

以上素材用于用户明确要求的本地毕业设计参考实现，原站资料及素材权利归其原权利人；本文件记录出处，不主张原创或另行授予许可。
