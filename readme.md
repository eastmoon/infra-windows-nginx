## Nginx for Winodws

此專案為一個 Nginx 管理工具，主要用於 Windows 作業系統，以 ```cli.bat``` 腳本控制 Nginx 開啟與關閉，並可指定導入的自定義腳本

### 指令

+ 初始化 Nginx

```
cli init
```
> 此功能為下載 ```version.rc``` 指定版本的 Nginx，並自動解壓縮後放置於目錄下；由於此功能會使用到 ```curl```、```tar``` 兩指令，請確保命令可於系統中正常運作

+ 啟動服務

```
cli start "<options>"
```
> 此功能為啟動 Nginx；主要 options 為 ( 需注意，使用 options 必須加上雙引號，避免 batch script 將此視為兩個獨立字串  )
> + ```--dev``` : 指定 src 目錄中的 *.conf 檔案，例如 ```--dev=sit``` 則使用 src\sit.conf 檔案

+ 關閉服務

```
cli down
```
> 此功能為關閉 Nginx 並移除相關 nginx.exe 的執行程序；在 cli start 時也會呼叫此命令，確保永遠僅有一個 Nginx 服務啟動中

+ 顯示狀態

```
cli status
```
> 此功能為顯示 Nginx 是否在執行中，此方式僅列出作業系統中正在執行的 nginx.exe，倘若無任何執行程序顯示則表示 Nginx 並未啟動

## 參考
