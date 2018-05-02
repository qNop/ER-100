.import Material 0.1 as Material
/**
*主要用于 js数字的计算
*/

//计算加法
function addMath(arg1,arg2) {
    var r1, r2, m,n;
    r1 = arg1.toString().split(".")[1].length
    r2 = arg2.toString().split(".")[1].length
    m = Math.pow(10, Math.max(r1, r2))
    n = (r1>=r2)?r1:r2;
    return ((arg1 * m + arg2 * m) / m).toFixed(n);
}

//计算减法
function subMath(arg1,arg2) {
    var r1, r2, m, n;
    r1 = arg1.toString().split(".")[1].length
    r2 = arg2.toString().split(".")[1].length
    m = Math.pow(10, Math.max(r1, r2));
    n = (r1 >= r2) ? r1 : r2;
    return ((arg1 * m - arg2 * m) / m).toFixed(n);
}
//获取系统时间 以 yyyy-MM-dd h:mm:ss格式
function getSysTime(){
    return new Date().toLocaleString(Qt.locale("ch_ZN"),"yyyy-MM-dd h:mm:ss")
}



