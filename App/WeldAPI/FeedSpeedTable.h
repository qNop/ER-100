#ifndef FEEDSPEEDTABLE_H
#define FEEDSPEEDTABLE_H
const int FeedSpeedTable[8][250]={
    //MAG D 实芯 1.2
    {1200,1208,1216,1224,1232,
     1240,1248,1256,1264,1272,
     1280,1288,1296,1304,1312,
     1320,1328,1336,1344,1352,
     1360,1368,1376,1384,1392,

     1400,1427,1455,1482,1509,
     1536,1564,1591,1618,1645,
     1673,1700,1736,1773,1809,
     1845,1882,1918,1955,1991,
     2027,2064,2100,2138,2177,  //98

     2215,2254,2292,2331,2369,
     2408,2446,2485,2523,2562,
     2600,2656,2711,2767,2822,
     2878,2933,2989,3044,3100,
     3155,3209,3264,3318,3373,

     3427,3482,3536,3591,3645,
     3700,3800,3900,4000,4100,
     4200,4300,4400,4482,4564,
     4645,4727,4809,4891,4973,
     5055,5136,5218,5300,5389, //198

     5478,5567,5656,5744,5833,
     5922,6011,6100,6189,6278,
     6367,6456,6544,6633,6722,
     6811,6900,6964,7027,7091,
     7155,7218,7282,7345,7409,

     7473,7536,7600,7720,7840,
     7960,8080,8200,8312,8425,
     8538,8650,8763,8875,8988,
     9100,9190,9280,9370,9460,
     9550,9640,9730,9820,9910, //298

     10000,10170,10340,10510,10680,
     10850,11020,11190,11360,11530,
     11700,11830,11960,12090,12220,
     12350,12480,12610,12740,12870,
     13000,13200,13400,13600,13800,

     14000,14200,14400,14600,14800,
     15000,15250,15500,15750,16000,
     16167,16333,16500,16667,16833,
     17000,17250,17500,17750,18000,
     18169,18338,18506,18675,18844,//398

     19013,19181,19350,19519,19688,
     19856,20025,20194,20363,20531,
     20700,20877,21054,21231,21408,
     21585,21762,21938,22115,22292,
     22469,22646,22823,23000,23111,

     23222,23333,23444,23556,23667,
     23778,23889,24000,24111,24222,
     24333,24444,24556,24667,24778,
     24889,25000,25000,25000,25000,
     25000,25000,25000,25000,25000//498
    },
    //MAG P 实芯 1.2
    {0,60,120,180,240,
     300,360,420,480,540,
     600,660,720,780,840,
     900,960,1020,1080,1140,
     1200,1280,1360,1440,1520,

     1600,1680,1760,1840,1920,
     2000,2080,2160,2240,2320,
     2400,2480,2560,2639,2720,
     2800,2879,2960,3040,3120,
     3199,3280,3360,3440,3520,//98

     3600,3679,3760,3840,3920,
     4000,4080,4160,4240,4320,
     4400,4480,4560,4640,4720,
     4800,4880,4960,5040,5120,
     5200,5279,5359,5440,5520,

     5600,5680,5759,5840,5920,
     6000,6100,6200,6300,6400,
     6500,6600,6700,6800,6900,
     7000,7080,7160,7240,7320,
     7400,7480,7560,7640,7720,//198

     7800,7900,8000,8100,8200,
     8300,8400,8500,8600,8700,
     8800,8900,9000,9100,9200,
     9300,9400,9500,9600,9700,
     9800,9900,10000,10100,10200,

     10300,10400,10500,10600,10700,
     10800,10900,11000,11100,11200,
     11300,11400,11500,11600,11700,
     11800,11900,12000,12100,12200,
     12300,12400,12500,12600,12700,//298

     12800,12920,13040,13160,13280,
     13400,13520,13640,13760,13880,
     14000,14120,14240,14360,14480,
     14600,14720,14840,14960,15080,
     15200,15340,15480,15620,15760,

     15900,16040,16180,16320,16460,
     16600,16760,16920,17080,17240,
     17400,17560,17720,17880,18040,
     18200,18360,18520,18680,18840,
     19000,19160,19320,19480,19640,//398

     19800,19960,20119,20279,20439,
     20599,20760,20920,21080,21240,
     21400,21560,21720,21880,22039,
     22200,22360,22520,22680,22840,
     23000,23000,23000,23000,23000,

     23000,23000,23000,23000,23000,
     23000,23000,23000,23000,23000,
     23000,23000,23000,23000,23000,
     23000,23000,23000,23000,23000,
     23000,23000,23000,23000,23000//498
    },
    //CO2  D 实芯 1.2
    {800,820,840,860,880,
     900,920,940,960,980,
     1000,1020,1040,1060,1080,
     1100,1120,1140,1160,1180,
     1200,1220,1240,1260,1280,

     1300,1320,1340,1360,1380,
     1400,1430,1460,1490,1520,
     1550,1580,1610,1640,1670,
     1700,1733,1767,1800,1833,
     1867,1900,1933,1967,2000,//98

     2050,2100,2150,2200,2250,
     2300,2350,2400,2450,2500,
     2562,2625,2688,2750,2812,
     2875,2938,3000,3067,3133,
     3200,3267,3333,3400,3467,

     3533,3600,3667,3733,3800,
     3867,3933,4000,4075,4150,
     4225,4300,4375,4450,4525,
     4600,4675,4750,4825,4900,
     5100,5300,5500,5700,5786,//198

     5871,5957,6043,6129,6214,
     6300,6392,6485,6577,6669,
     6762,6854,6946,7038,7131,
     7223,7315,7408,7500,7625,
     7750,7875,8000,8125,8250,

     8375,8500,8583,8667,8750,
     8833,8917,9000,9083,9167,
     9250,9333,9417,9500,9612,
     9725,9838,9950,10062,10175,
     10288,10400,10500,10600,10700,//298

     10800,10900,11000,11100,11200,
     11314,11429,11543,11657,11771,
     11886,12000,12094,12188,12281,
     12375,12469,12562,12656,12750,
     12844,12938,13031,13125,13219,

     13312,13406,13500,14000,14500,
     15000,15600,16200,16800,17400,
     18000,18133,18267,18400,18533,
     18667,18800,18933,19067,19200,
     19333,19467,19600,19733,19867,//398

     20000,20200,20400,20600,20800,
     21000,21200,21400,21600,21800,
     22000,22267,22533,22800,23067,
     23333,23600,23800,24000,24200,
     24400,24600,24800,25000,25000,

     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000//498
    },
    //CO2  D 药芯 1.2
    {800,830,860,890,920,
     950,980,1010,1040,1070,
     1100,1130,1160,1190,1220,
     1250,1280,1310,1340,1370,
     1400,1430,1460,1490,1520,

     1550,1580,1610,1640,1670,
     1700,1800,1900,2000,2100,
     2200,2300,2400,2500,2600,
     2700,2767,2833,2900,2967,
     3033,3100,3167,3233,3300,//98

     3367,3433,3500,3567,3633,
     3700,3780,3860,3940,4020,
     4100,4180,4260,4340,4420,
     4500,4660,4820,4980,5140,
     5300,5410,5520,5630,5740,

     5850,5960,6070,6180,6290,
     6400,6490,6580,6670,6760,
     6850,6940,7030,7120,7210,
     7300,7410,7520,7630,7740,
     7850,7960,8070,8180,8290,//198

     8400,8560,8720,8880,9040,
     9200,9360,9520,9680,9840,
     10000,10130,10260,10390,10520,
     10650,10780,10910,11040,11170,
     11300,11420,11540,11660,11780,

     11900,12020,12140,12260,12380,
     12500,12750,13000,13250,13500,
     13750,14000,14250,14500,14750,
     15000,15150,15300,15450,15600,
     15750,15900,16050,16200,16350,//298

     16500,16650,16800,16950,17100,
     17250,17400,17550,17700,17850,
     18000,18160,18320,18480,18640,
     18800,18960,19120,19280,19440,
     19600,19760,19920,20080,20240,

     20400,20560,20720,20880,21040,
     21200,21380,21560,21740,21920,
     22100,22280,22460,22640,22820,
     23000,23200,23400,23600,23800,
     24000,24200,24400,24600,24800,//398

     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,

     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000,
     25000,25000,25000,25000,25000//498
    },
    //MAG D 实芯 1.6
    {1000,1005,1010,1015,1020,
     1025,1030,1035,1040,1045,
     1050,1055,1060,1065,1070,
     1075,1080,1085,1090,1095,
     1100,1105,1110,1115,1120,

     1125,1130,1135,1140,1145,
     1150,1155,1160,1165,1170,
     1175,1180,1185,1190,1195,
     1200,1220,1240,1260,1280,
     1300,1320,1340,1360,1380,//98

     1400,1420,1440,1460,1480,
     1500,1520,1540,1560,1580,
     1600,1627,1653,1680,1707,
     1733,1760,1787,1813,1840,
     1867,1893,1920,1947,1973,

     2000,2027,2053,2080,2107,
     2133,2160,2187,2213,2240,
     2267,2293,2320,2347,2373,
     2400,2440,2480,2520,2560,
     2600,2640,2680,2720,2760,//198

     2800,2840,2880,2920,2960,
     3000,3040,3080,3120,3160,
     3200,3280,3360,3440,3520,
     3600,3633,3667,3700,3733,
     3767,3800,3833,3867,3900,

     3933,3967,4000,4050,4100,
     4150,4200,4250,4300,4350,
     4400,4480,4560,4640,4720,
     4800,4860,4920,4980,5040,
     5100,5160,5220,5280,5340,//298

     5400,5460,5520,5580,5640,
     5700,5760,5820,5880,5940,
     6000,6050,6100,6150,6200,
     6250,6300,6350,6400,6450,
     6500,6550,6600,6650,6700,

     6750,6800,6850,6900,6950,
     7000,7067,7133,7200,7267,
     7333,7400,7467,7533,7600,
     7667,7733,7800,7867,7933,
     8000,8067,8133,8200,8267,//398

     8333,8400,8467,8533,8600,
     8667,8733,8800,8867,8933,
     9000,9050,9100,9150,9200,
     9250,9300,9350,9400,9450,
     9500,9550,9600,9650,9700,

     9750,9800,9850,9900,9950,
     10000,10100,10200,10300,10400,
     10500,10600,10700,10800,10900,
     11000,11100,11200,11300,11400,
     11500,11600,11700,11800,11900//498
    },
    //MAG P 实芯 1.6
    {   0,40,80,120,160,
        199,240,280,320,359,
        400,440,480,520,560,
        600,640,680,720,760,
        800,820,840,860,880,

        900,920,940,960,980,
        1000,1040,1080,1120,1160,
        1200,1240,1280,1319,1360,
        1400,1439,1480,1520,1560,
        1599,1640,1680,1720,1760,//98

        1800,1839,1880,1920,1960,
        2000,2040,2080,2120,2160,
        2200,2220,2240,2260,2280,
        2300,2320,2340,2360,2380,
        2400,2440,2480,2520,2560,

        2600,2640,2680,2720,2760,
        2800,2840,2879,2920,2960,
        3000,3040,3080,3120,3160,
        3200,3240,3280,3320,3360,
        3400,3440,3480,3520,3560,//198

        3600,3639,3679,3720,3760,
        3800,3840,3879,3920,3960,
        4000,4040,4080,4120,4160,
        4200,4240,4280,4320,4360,
        4400,4440,4480,4520,4560,

        4600,4640,4680,4720,4760,
        4800,4840,4880,4920,4960,
        5000,5040,5080,5120,5160,
        5200,5240,5279,5319,5359,
        5399,5440,5480,5520,5560,//298

        5600,5640,5680,5720,5759,
        5800,5840,5880,5920,5960,
        6000,6040,6080,6120,6160,
        6200,6240,6280,6320,6360,
        6400,6460,6520,6580,6640,

        6700,6760,6820,6880,6940,
        7000,7060,7120,7180,7240,
        7300,7360,7420,7480,7540,
        7600,7660,7720,7779,7839,
        7899,7960,8019,8080,8139,//398

        8200,8260,8320,8380,8440,
        8500,8560,8620,8680,8740,
        8800,8860,8920,8980,9040,
        9100,9160,9219,9280,9340,
        9400,9460,9519,9580,9639,

        9700,9760,9820,9880,9940,
        10000,10080,10160,10240,10320,
        10400,10480,10560,10640,10720,
        10800,10880,10960,11040,11120,
        11200,11280,11360,11440,11520//498
    },
    //CO2  D 实芯 1.6
    {400,420,440,460,480,
     500,520,540,560,580,
     600,620,640,660,680,
     700,720,740,760,780,
     800,820,840,860,880,

     900,920,940,960,980,
     1000,1020,1040,1060,1080,
     1100,1120,1140,1160,1180,
     1200,1220,1240,1260,1280,
     1300,1320,1340,1360,1380,//98

     1400,1430,1460,1490,1520,
     1550,1580,1610,1640,1670,
     1700,1730,1760,1790,1820,
     1850,1880,1910,1940,1970,
     2000,2027,2053,2080,2107,

     2133,2160,2187,2213,2240,
     2267,2293,2320,2347,2373,
     2400,2440,2480,2520,2560,
     2600,2640,2680,2720,2760,
     2800,2880,2960,3040,3120,//198

     3200,3240,3280,3320,3360,
     3400,3440,3480,3520,3560,
     3600,3640,3680,3720,3760,
     3800,3840,3880,3920,3960,
     4000,4040,4080,4120,4160,

     4200,4280,4360,4440,4520,
     4600,4640,4680,4720,4760,
     4800,4840,4880,4920,4960,
     5000,5040,5080,5120,5160,
     5200,5240,5280,5320,5360,//298

     5400,5480,5560,5640,5720,
     5800,5880,5960,6040,6120,
     6200,6253,6307,6360,6413,
     6467,6520,6573,6627,6680,
     6733,6787,6840,6893,6947,

     7000,7100,7200,7300,7400,
     7500,7600,7700,7800,7900,
     8000,8067,8133,8200,8267,
     8333,8400,8467,8533,8600,
     8667,8733,8800,8867,8933,//398

     9000,9100,9200,9300,9400,
     9500,9600,9700,9800,9900,
     10000,10100,10200,10300,10400,
     10500,10600,10700,10800,10900,
     11000,11100,11200,11300,11400,

     11500,11600,11700,11800,11900,
     12000,12100,12200,12300,12400,
     12500,12600,12700,12800,12900,
     13000,13100,13200,13300,13400,
     13500,13600,13700,13800,13900//498
    },
    //CO2  D 药芯 1.6
    {300,318,335,352,370,
     388,405,422,440,458,
     475,492,510,528,545,
     562,580,598,615,632,
     650,668,685,702,720,

     738,755,772,790,808,
     825,842,860,878,895,
     912,930,948,965,982,
     1000,1140,1280,1420,1560,
     1700,1740,1780,1820,1860,//98

     1900,1940,1980,2020,2060,
     2100,2120,2140,2160,2180,
     2200,2220,2240,2260,2280,
     2300,2320,2340,2360,2380,
     2400,2420,2440,2460,2480,

     2500,2560,2620,2680,2740,
     2800,2880,2960,3040,3120,
     3200,3280,3360,3440,3520,
     3600,3660,3720,3780,3840,
     3900,3960,4020,4080,4140,//198

     4200,4300,4400,4500,4600,
     4640,4680,4720,4760,4800,
     4840,4880,4920,4960,5000,
     5040,5080,5145,5236,5327,
     5418,5509,5600,5657,5714,

     5771,5829,5886,5943,6000,
     6140,6280,6420,6560,6700,
     6755,6809,6864,6918,6973,
     7027,7082,7136,7191,7245,
     7300,7352,7404,7456,7507,//298

     7559,7611,7663,7715,7767,
     7819,7870,7922,7974,8030,
     8091,8152,8212,8273,8333,
     8394,8455,8515,8576,8636,
     8697,8758,8818,8879,8939,

     9000,9200,9400,9600,9800,
     10000,10120,10240,10360,10480,
     10600,10720,10840,10960,11080,
     11200,11320,11440,11560,11680,
     11800,11886,11971,12057,12143,//398

     12229,12314,12400,12475,12550,
     12625,12700,12775,12850,12925,
     13000,13200,13400,13600,13800,
     14000,14111,14222,14333,14444,
     14556,14667,14778,14889,15000,

     15167,15333,15500,15667,15833,
     16000,16100,16200,16300,16400,
     16500,16600,16700,16800,16900,
     17000,17100,17200,17300,17400,
     17500,17600,17700,17800,17900//498
    }
};

#endif