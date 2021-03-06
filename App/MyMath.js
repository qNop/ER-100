.import Material 0.1 as Material
/**
*主要用于 js数字的计算
*/

function addMath(arg1,arg2) {
    var r1, r2, m,n;
    try { r1 = arg1.toString().split(".")[1].length } catch (e) { r1 = 0 }
    try { r2 = arg2.toString().split(".")[1].length } catch (e) { r2 = 0 }
    m = Math.pow(10, Math.max(r1, r2))
    n = (r1>=r2)?r1:r2;
    return ((arg1 * m + arg2 * m) / m).toFixed(n);
}

function subMath(arg1,arg2) {
    var r1, r2, m, n;
       try { r1 = arg1.toString().split(".")[1].length } catch (e) { r1 = 0 }
       try { r2 = arg2.toString().split(".")[1].length } catch (e) { r2 = 0 }
       m = Math.pow(10, Math.max(r1, r2));
       n = (r1 >= r2) ? r1 : r2;
       return ((arg1 * m - arg2 * m) / m).toFixed(n);
}

function getSysTime(){
        return new Date().toLocaleString(Qt.locale("ch_ZN"),"yyyy-MM-dd h:mm:ss")
}



