Shader "Unlit/SkyStarShader"
{
    Properties
    {
        _SquareNum("SquareNum",int) = 10
        _NightColor("NightColor", Color) = (0, 0, 0, 0)
        _MoonColor("MoonColor", Color) = (0, 0, 0, 0)
        }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque"
            "Queue"="Background"
            "PreviewType"="SkyBox"     
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float3 worldPos : WORLD_POS;
                float4 pos : SV_POSITION;
            };

            int _SquareNum;
            float4 _MoonColor;
            float4 _NightColor;

            v2f vert (appdata v)
            {
                v2f o;
                // オブジェクト座標行列をかける
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex); 
                return o;
            }
            
            //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            //ランダムな値を返す
            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)), dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = normalize(i.worldPos);

                // x軸とz軸の直交座標における(x,y)のラジアンで返す
                float radianXZ = atan2(dir.x, dir.z);
                // Yのsinの逆関数　-PI/2 ~ PI/2でY軸のラジアンを取ってくる
                float radianY = asin(dir.y);
                float2 radian =(radianXZ, radianY);
                float2 uv = radian / float2(UNITY_PI / 2, UNITY_PI / 2);

                uv *= _SquareNum; // 格子を作成

                // マス目の起点を作成
                float2 ist = floor(uv);
                // 格子の座標を小数点に正規化
                float2 fst = frac(uv);

                float4 color = 0;

                // 周囲のマス目を探索（ボロのい
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        // 周りのマス目の起点　x => -1 or 0 or 1 y => -1 or 0 or 1
                        float2 neighbor = float2(x, y);

                        // タイルの中の点の位置＝＞現在の格子の座標(ist) を基準にオフセット（neighbor）
                        float2 p = random2(ist + neighbor);
// https://thebookofshaders.com/12/?lan=jp
                        
                        // 処理対象(いまいる)の座標(fst)と(neighbor隣のマス目の基準点)にp
                        float2 neighborPoint = neighbor + p;
                        float2 diff = neighborPoint - fst;

                        // 色を星ごとにランダムで当てはまる星の座標を利用
                        float r = rand(p + 1);
                        float g = rand(p + 2);
                        float b = rand(p + 3);

                        // ランダムColor
                        float4 randColor = float4(r, g, b, 1);
                        float dist = length(diff);

                       // 補間 1 or 0
                        float interPolation = 1 - step(0.01, dist);
    // lerp で色を付ける 0 => NightColor 1 => randColorを出力
                        color += lerp(_NightColor, randColor, interPolation);
// グリッドの表示
                        color.r += step(0.98, fst.x) + step(0.98, fst.y);
                    }
                }
                if (uv.y > _SquareNum * 0.75)
                {
                    color = _MoonColor;
                }
                return color;
            }
            
            ENDCG
        }
    }
}
