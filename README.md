# 物流无人机路径规划

Path Plan for Delivery Unmanned Aerial Vehicle (abbr.PP4DUAV)

## 本科毕业论文最终稿 / Final Thesis in Simplified Chinese

[Google Drive](https://drive.google.com/file/d/1yprHxeqso2e5kB5ZR_JG73kwGDX7GXu5/view)

## 背景介绍

### 编程环境

- **语言**：Python 3.10.0
- **依赖库**（更新的版本可能报错...）：numpy>=1.22.1；openpyxl>=3.0.9；matplotlib>=3.5.1；pandas>=1.4.0

### 地图环境

[香港九龙三维地图模型](https://www.hkmapservice.gov.hk/OneStopSystem/map-search?product=OSSCatB)转换的数字高程地图模型（DEM）

![地图环境](/images/map.png)

### 规划分类

- **局部路径规划**：面向单个物流无人机的路径规划
- **全局路径规划**：面向整个物流系统多个无人机路径规划

### 规划目的

安全、高效、经济，即运行符合规范并保障安全裕度，系统配送时间和货物晚点最短，无人机平均能耗最低

## 主要文件

### pp4duav.py

主程序所在位置

### pp4duav.sh, pp4duav.bat

跑程序的多线程示例，唤起主程序的全局路径规划

### HKKowloon5.xlsx

地图环境文件，按XY轴以5m为水平分辨率存储了地图高程信息，用于局部路径规划的避障

### HKKowloonDA.csv

飞行风险区（Danger Area）定义，按XY坐标存储危险区坐标点的飞行风险。飞行风险值：

- **0.5**：危险
- **0.8**：限制
- **1**：禁区

### HKKowloonPlanned.xlsx

已经规划的无人机局部路径数据文件

全局路径规划直接调用局部路径规划数据，计算飞行用时和能耗，得出适应度

### HKKowloonTD.csv

无人机物流系统的物流网点数据，其中字母（A, B, ...）为配送中心（Terminal），数字（1, 2, ...）为配送点（Distributor）

目前全局路径规划仅支持**多个配送中心送往所属配送点**的配送任务规划，否则会报TypeError或出现非法解

### HKKowloonTasks.csv

配送任务定义文件

### HKKowloonUAVs.csv

无人机定义文件，定义各无人机的初始位置和性能

为全局路径规划预留了多机型的扩展空间，但**尚未实现**

### GirdPlacerToCSV.mcr

3dsMAX的脚本，用于生成.max模型的数字高程地图模型DEM文件所需的x,y,z坐标信息，生成的数据可在Python中使用pandas.read_csv载入，再用pandas.pivot_table转化为DEM完成处理

## 实现功能

### 无人机飞行路径识别码（ID）

识别无人机的飞行路径，识别货物类型和重量，飞行路径起止点，路径规划方式，并存储必要数据，既可以展示当前规划路径必要信息，亦可用作DataFrame的索引或字典的键名

### 局部路径规划（PathPlanner）

#### 算法

Theta\*算法（基于[A\*算法](https://github.com/zhm-real/PathPlanning)加入视线检查的改进算法）

#### 功能

- 单个无人机飞行路径的规划（plan）
- 无人机飞行路径数据的保存（save）和读取（load）
- 无人机飞行性能分析（flight_analysis, plan方法直接调用）
- 飞行路径可视化（visualize）

#### 问题

- 视线检查二分法采样，加之DEM可能不准确，放进模型中直线飞行路径可能存在碰撞
- 可能陷入局部最优，尽管陷入后会检测并调整代价系数（cost_ratio），但耗时明显增加

#### 结果示例

程序可视化示例（地图数据超过200\*200后可视化卡顿严重）

![飞行路径三维图](/images/theta-star_path.png)

![飞行路径俯视图](/images/theta-star_route.png)

### 全局路径规划（TaskAssigner）

#### 算法

多染色体遗传算法（每个个体有多条染色体的遗传算法）

#### 功能

- 多配送中心的无人机全局路径规划（optimize）

#### 问题

- 仅支持配送中心发往配送点的配送任务路径规划
- 遗传进化过程中小概率出现异常染色体和基因（不在预期），故加入了染色体完整性检查
- 无人机配送时间窗仅考虑晚点和最晚送达时间，假设配送点容量无限大

#### 结果示例

适应度收敛图

![适应度收敛](/images/ga_fit.png)

无人机飞行路径示意图

![飞行路径示意](/images/ga_route.png)

无人机任务执行时序图（非上图结果）

![任务执行时序](/images/ga_itinerary.png)

## 重要参考资料

1. 许卫卫. 复杂低空物流无人机路径规划技术研究[D]. 南京航空航天大学, 2020.
2. 陈呈频, 韩胜军, 鲁建厦, 等. 多车场与多车型车辆路径问题的多染色体遗传算法[J]. 中国机械工程, 2018, 29(02): 218-223.
3. 叶多福, 刘刚, 何兵. 一种多染色体遗传算法解决多旅行商问题[J]. 系统仿真学报, 2019, 31(01): 36-42.
