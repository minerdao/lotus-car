# Filecoin Datacap操作流程

## 1. 打包car文件
#### 编译打包工具
先编译打包工具，需要安装Go 1.90+。
```sh
$ git clone https://github.com/minerdao/lotus-car.git
$ cd lotus-car
$ go build -o lotus-car
```

#### 打包car文件
安装完以后，执行以下命令打包car文件：
```sh
./lotus-car generate --input=/mnt/md0/1712/1712.json --parent=/mnt/md0/1712/raw --tmp-dir=/mnt/md0/tmp1 --quantity=320 --out-dir=/mnt/md0/car/dataset_1712_3_320  --out-file=/home/fil/csv/dataset_1712_3_320.csv
```
参数说明：
- **--input**：原始文件对应的索引文件路径，`.json`格式，通过[lotus-car](https://github.com/minerdao/lotus-car.git)仓库中`python3 main.py -i`来生成。  
  ⚠️ 注意生成索引文件时，需先修改`main.py`中的数据集根目录和数据集名称。
- **--parent**：原始文件所在目录，一般放在`raw`目录下。
- **--tmp-dir**：打包过程中的临时文件路径，需放在ssd上。
- **--quantity**：一次打包的car文件数量(320个 = 10TiB)。
- **--out-dir**：car文件的保存位置。
- **--out-file**：打包完car文件后，输出的csv文件名称及路径，该文件用于Client发订单。

一台4块以上nVME U.2组成的Raid0的机器，可启动2个进程同时打包。  
每天大约可打包**15TiB**的数据，每个car文件(18GiB)打包时间约5～6分钟。

#### 同步car文件到存储机上
打包好的car文件，需移动到存储机器上，启动一个进程，运行[lotus-car](https://github.com/minerdao/lotus-car.git)仓库中`sync.py`来监听打包好的car文件，并同步到指定的存储目录。

**⚠️ 注意：运行前需修改sync.py中的对应目录**
```sh
$ python3 sync.py
```

## 2. Client发单
打包完成后，将上面`--out-file`对应的csv文件发给Client来发布存储订单。

## 3. Miner接单
Miner接单需先配置好Boost，关于Boost的配置参照: https://boost.filecoin.io/getting-started/getting-started。

存储订单发送完毕后，将生成`dataset_1711_4_3200.csv`的一个csv索引文件，Miner通过该文件来导入离线订单。

使用[lotus-car](https://github.com/minerdao/lotus-car.git)仓库中的`import-deals.sh`脚本来导入订单，注意修改脚本中car文件所在的目录。
```sh
$ ./import-deals.sh dataset_1711_4_3200
# 后面跟上数据集名称即可
```