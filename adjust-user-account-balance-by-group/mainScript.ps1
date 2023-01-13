$servercommand = "C:\Program Files\PaperCut MF\server\bin\win\server-command.exe"
$groupList = Import-Csv .\group_list.csv -Encoding Default
$logFolder = Join-Path .\ "log"
<#$foldernameで指定したディレクトリに特定のディレクトリがあるかを確認。ディレクトリがない場合は作成する。#>
 function confirm_directory($path){
    if(Test-Path $path){
        }else{
            New-Item $path -ItemType Directory
        }
}

#ログファイルを生成する
function log_file($LogString){
    $Time = (Get-Date).ToString("yyyy-MM-dd")
    $logfile =  $Time + "_" +  "setuserbalance.log"
    $logpath = Join-Path $logFolder $logfile
    $Now = Get-Date
    # Log 出力文字列に時刻を付加(YYYY/MM/DD HH:MM:SS.MMM $LogString)
    $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "
    $Log += $logstring
    Write-Output $Log | Out-File -FilePath $logpath -Encoding Default -append
}

#成功/失敗を記述する関数
function resultMsg1($result){
    if($result){
        return "INFO","ポイントを設定しました。"
}else{
    return "ERROR","コマンドの実行に失敗しました。PowerShellの設定内容を確認してください。"
    }
}

#ポイントを付与する関数
function adjustUserAccountBalanceByGroup(){
	foreach($group in $groupList){
        $name = $group.グループ
        $account = $group.マルチ個人アカウント
        $point = $group.付与ポイント
        $limit = $group.上限ポイント
        Write-Host($name + $point + $limit + "クォータースケジューリング" + $account)
        cmd /C $servercommand adjust-user-account-balance-by-group-up-to $name $point $limit クォータースケジューリング $account
        $result = echo $?
        $info,$massage = resultMsg1($result)
        log_file($info,$name,$account,$point,$massage)
    }

}

#logフォルダの作成
confirm_directory($logFolder)
#処理開始
log_file("<Start>")
#ポイント設定処理
adjustUserAccountBalanceByGroup
#処理終了
log_file("<End>")