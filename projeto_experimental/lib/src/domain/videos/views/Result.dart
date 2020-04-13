import 'dart:ui';
import 'dart:async';
import 'dart:convert';

import '../../../../src/assets/colors/MyColors.dart';
import '../api/VideoApi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:number_display/number_display.dart';

final display = createDisplay(decimal: 2);

class Result extends StatefulWidget {
  Result({Key key}) : super(key: key);

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {  
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var dataChart;

  List<Map<String, Object>> _data = [{ 'name': 'Please wait', 'value': 0 }];

  _createData() async {
    await Future.delayed(Duration(seconds: 4));

    var dataObj = dataChart;
    // [{
    //   'name': 'Jan',
    //   'value': 8726.2453,
    // }, {
    //   'name': 'Feb',
    //   'value': 2445.2453,
    // }, {
    //   'name': 'Mar',
    //   'value': 6636.2400,
    // }, {
    //   'name': 'Apr',
    //   'value': 4774.2453,
    // }, {
    //   'name': 'May',
    //   'value': 1066.2453,
    // }, {
    //   'name': 'Jun',
    //   'value': 4576.9932,
    // }, {
    //   'name': 'Jul',
    //   'value': 8926.9823,
    // }];

    this.setState(() { this._data = dataObj;});
  }

  _getResult(_createData) async
  {
    var resultData = await new VideoApi().getJSONResult();
    var data = jsonDecode(resultData.toString());
    setState(() {
      dataChart = [{ 'name':'Felicidade', 'value':data['felicidadeMedia'] }, 
                   { 'name':'Tristeza', 'value':data['tristezaMedia'] }, 
                   { 'name':'Surpresa', 'value':data['surpresaMedia'] }, 
                   { 'name':'Medo', 'value':data['medoMedia'] }, 
                   { 'name':'Neutralidade', 'value':data['neutralidadeMedia'] }];
    });
    _createData();
  }

  
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _getResult(_createData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,      
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back, color: MyColors.grey, size: 25),
              onPressed: () { Navigator.pushReplacementNamed(context, '/Home'); },              
            );
          },
        ),        
        title: Text("Resultados", style: TextStyle(color: MyColors.grey)),        
        backgroundColor: MyColors.white,
        elevation: 0.0, //para tirar a sombra
      ),
      body: Center(         
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  child: Text('Gráfico de Barras', style: TextStyle(fontSize: 20, color: MyColors.grey, fontWeight: FontWeight.bold)),
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
                ),
                Text('- A data aparecerá em alguns segundos', style: TextStyle(color: MyColors.grey)),
                Text('- toque nas barras para ver mais informações', style: TextStyle(color: MyColors.grey)),
                Container(
                  child: Echarts(
                    option: '''
                      {
                        title: {
                            text: 'Porcentagem das Emoções',                            
                            left: 'center'
                        },
                        dataset: {
                          dimensions: ['name', 'value'],
                          source: ${jsonEncode(_data)},
                        },
                        color: ['#3398DB'],
                        legend: {
                          data: ['直接访问', '背景'],
                          show: false,
                        },
                        grid: {
                          left: '0%',
                          right: '0%',
                          bottom: '5%',
                          top: '7%',
                          height: '85%',
                          containLabel: true,
                          z: 22,
                        },
                        xAxis: [{
                          type: 'category',
                          gridIndex: 0,
                          axisTick: {
                            show: false,
                          },
                          axisLine: {
                            lineStyle: {
                              color: '#0c3b71',
                            },
                          },
                          axisLabel: {
                            show: true,
                            color: 'rgb(170,170,170)',
                            formatter: function xFormatter(value, index) {
                              if (index === 6) {
                                return `\${value}\\n*`;
                              }
                              return value;
                            },
                          },
                        }],
                        yAxis: {
                          type: 'value',
                          gridIndex: 0,
                          splitLine: {
                            show: false,
                          },
                          axisTick: {
                              show: false,
                          },
                          axisLine: {
                            lineStyle: {
                              color: '#0c3b71',
                            },
                          },
                          axisLabel: {
                            color: 'rgb(170,170,170)',
                          },
                          splitNumber: 12,
                          splitArea: {
                            show: true,
                            areaStyle: {
                              color: ['rgba(250,250,250,0.0)', 'rgba(250,250,250,0.05)'],
                            },
                          },
                        },
                        series: [{
                          name: '合格率',
                          type: 'bar',
                          barWidth: '50%',
                          xAxisIndex: 0,
                          yAxisIndex: 0,
                          itemStyle: {
                            normal: {
                              barBorderRadius: 5,
                              color: {
                                type: 'linear',
                                x: 0,
                                y: 0,
                                x2: 0,
                                y2: 1,
                                colorStops: [
                                  {
                                    offset: 0, color: '#E53935',
                                  },
                                  {
                                    offset: 1, color: '#E53935',
                                  },
                                  {
                                    offset: 1, color: '#E53935',
                                  },
                                ],
                              },
                            },
                          },
                          zlevel: 11,
                        }],
                      }
                    ''',
                    extraScript: '''
                      chart.on('click', (params) => {
                        if(params.componentType === 'series') {
                          Messager.postMessage(JSON.stringify({
                            type: 'select',
                            payload: params.dataIndex,
                          }));
                        }
                      });
                    ''',
                    onMessage: (String message) {
                      Map<String, Object> messageAction = jsonDecode(message);
                      print(messageAction);
                      if (messageAction['type'] == 'select') {
                        final item = _data[messageAction['payload']];
                        // _scaffoldKey.currentState.showSnackBar(                         
                        //   SnackBar(
                        Fluttertoast.showToast(
                            msg: item['name'].toString() + ': ' + display(item['value']),
                            toastLength: Toast.LENGTH_SHORT,
                          );
                      }
                    },
                  ),
                  width: 300,
                  height: 250,
                ),
                Padding(padding: EdgeInsets.only(top: 30)), 
                Padding(
                  child: Text('Gráfico de Pizza', style: TextStyle(fontSize: 20, color: MyColors.grey, fontWeight: FontWeight.bold)),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                ),
                Text('- A data aparecerá em alguns segundos', style: TextStyle(color: MyColors.grey)), 
                Text('- toque nas áreas para ver mais detalhes', style: TextStyle(color: MyColors.grey)),                
                Container(
                  child: Echarts(
                    option: '''
                      {
                        title: {
                            text: 'Porcentagem das Emoções',                            
                            left: 'center'
                        },
                        tooltip: {
                            trigger: 'item',
                            formatter: '{a} <br/>{b} : {c} ({d}%)'
                        },
                        legend: {
                            type: 'scroll',
                            orient: 'vertical',
                            right: 10,
                            top: 20,
                            bottom: 20,
                            data: ${jsonEncode(_data)},

                            selected: ${jsonEncode(_data)}
                        },
                        series: [
                            {
                                name: '姓名',
                                type: 'pie',
                                radius: '55%',
                                center: ['40%', '50%'], 
                                data:  ${jsonEncode(_data)},                               
                                emphasis: {
                                    itemStyle: {
                                        shadowBlur: 10,
                                        shadowOffsetX: 0,
                                        shadowColor: 'rgba(0, 0, 0, 0.5)'
                                    }
                                }
                            }
                        ],
                      }
                    ''',                    
                  ),
                  width: 300,
                  height: 250,
                ),               
                
                Padding(padding: EdgeInsets.only(top: 30)), 
              ],
            ),
          ),      
      ),
    );
  }
}
