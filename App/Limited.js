//.import Material 0.1 as Material

//function limitedMath(start,end){
//    var resArray=new Array(0);
//    var temp;
//    for(var i=start;i<end;i++){
//        var res=limitedTable.get(i);
//        if((typeof(res.C1)==="string")&&(res.C1!=="")){
//            temp=res.C1.split("/")
//            resArray.push(temp[0])
//            resArray.push(temp[1])
//            resArray.push(temp[2])
//        }else{
//            resArray.push("0")
//            resArray.push("0")
//            resArray.push("0")
//        }
//        if((typeof(res.C2)==="string")&&(res.C2!=="")){
//            temp=res.C2.split("/")
//            resArray.push(temp[0])
//            resArray.push(temp[1])
//        }else{
//            resArray.push("0")
//            resArray.push("0")
//        }
//        if((typeof(res.C3)==="string")&&(res.C3!=="")){
//            temp=res.C3.split("/")
//            resArray.push(temp[0])
//            resArray.push(temp[1])}
//        else{
//            resArray.push("0")
//            resArray.push("0")
//        }
//        if((typeof(res.C4)==="string")&&(res.C4!=="")){
//            temp=res.C4.split("/")
//            resArray.push(temp[0])
//            resArray.push(temp[1])
//        } else{
//            resArray.push("0")
//            resArray.push("0")
//        }
//        if((typeof(res.C5)==="string")&&(res.C5!==""))
//            resArray.push(res.C5)
//        else
//            resArray.push("0");
//        if((typeof(res.C6)==="string")&&(res.C6!==""))
//            resArray.push(res.C6)
//        else
//            resArray.push("0");
//        if((typeof(res.C7)==="string")&&(res.C7!==""))
//            resArray.push(res.C7)
//        else
//            resArray.push("0");
//        if((typeof(res.C8)==="string")&&(res.C8!==""))
//            resArray.push(res.C8)
//        else
//            resArray.push("0");
//        if((typeof(res.C9)==="string")&&(res.C9!=="")){
//            temp=res.C9.split("/")
//            resArray.push(temp[0])
//            resArray.push(temp[1])
//        }else{
//            resArray.push("0")
//            resArray.push("0")
//        }
//        if((typeof(res.C10)==="string")&&(res.C10!=="")){
//            resArray.push(res.C10)
//        }else{
//            resArray.push("0")
//        }
//    }
//    return resArray;
//}

//function getLimitedTableJson(dataBase,tablename,id){
//    var result,str;
//    str="SELECT * FROM "+tablename+ " WHERE C11 "+" = "+"\'"+id+"\'";
//    console.log(str)
//    if(typeof(tablename)==="string"){
//        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
//        var value=new Array(0);
//        /*遍寻所有数据转换成json格式*/
//        for(var i=0;i<result.rows.length;i++){
//            //result.rows.item返回的就是json object不需要在弄
//            value.push(result.rows.item(i));
//        }
//        console.log(value)
//        return value;
//    }else
//        return -1;
//}

WorkerScript.onMessage = function(message) {
    var error="";
      console.log("message.limitedRulesName"+message.limitedRulesName)
    if((message.limitedRulesName!=="")&&(typeof(message.limitedRulesName)==="string")){
        var res=Material.UserData.getLimitedTableJson(message.limitedRulesName,message.index)
        message.limitedTable.clear();
        if((typeof(res)==="object")&&(res.length)){
            for(var i=0;i<res.length;i++){
                //删除object 里面C11属性
                delete res[i].C11
                message.limitedTable.append(res[i])
            }
            message.limitedTable.sync();
        }else
            error=message.limitedRulesName+"数据不存在！";
    }
    WorkerScript.sendMessage({"error":error})
}
