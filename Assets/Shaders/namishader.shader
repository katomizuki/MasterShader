Shader "Unlit/namishader"
{
    Properties
    {
        _SquareNum("SquareNum", int) = 5
        [HDR] _WaterColor("WaterColor", Color) = (0.09, 0.89, 1, 1)
        _WaveSpeed("WaveSpeed", Range(1, 10)) = 1
        _FoamPower("FoamPower", Range(0, 1)) = 0.6
        FoamColor("FoamColor", Color) = (1, 1, 1, 1)
        EdgeColor("EdgeColor", Color) = (1, 1, 1, 1)
        DepthColor("DepthColor", float) = 1.0
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "Queue"="Transparent" 
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            uniform sampler2D _CameraDepthTexture;
            int _SquareNum;
            fixed4 _WaterColor;
            fixed4 _FoamColor;
            fixed4 _EdgeColor;
            float _WaveSpeed;
            float _FormPower;
            float _DepthFactor;

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 st = i.uv;
                st  *= _SquareNum;
                float2 ist = floor(st);
                float2 fst = frac(st);

                float4 waveColor = 0;
                float m_dist = 100;
// 自身を含む周囲のマスを探索
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        // 周辺のエリア
                        float2 neighbor = float2(x,y);

                        // 点のxy座標
                        float2 p = 0.5 + 0.5 * sin(random2(ist + neighbor) + _Time.x * _WaveSpeed);
                        // 点と処理対象のピクセルとの距離ベクトル
                        float2 diff = neighbor + p - fst;
                        // 距離を更新していく
                        m_dist = min(m_dist, length(diff));

                        //
                        waveColor = lerp(_WaterColor,_FoamColor, smoothstep(1 - _FormPower, 1, m_dist));
                    }
                }

                // 深度の計算
                // _CameraDepthTextureがCameraのDepthモードにすると深度テクスチャが代入する。テクスチャ座標を適切なものに変換。（プラットフォームの違いを吸収してくれる）
                //SAMPLE_DEPTH_TEXTURE_PROJで深度テクスチャを参照しレンダリングしてくれる。
                //SAMPLE_DEPTH_TEXTURE_PROJ=> 
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD((i.screenPos)));
                // 深度テクスチャをLinerEyeDepthに入れればカメラ起点での深度をとってこれる。カメラのnearとfarの線形をしてくれる
                
                half depth = LinearEyeDepth(depthSample);
                //　オブジェクトのカメラ深度値から スクリーン深度値を引くことで交差している部分(0になる）がわかる。
                half screenDepth = depth - i.screenPos.w;
                // 交差している部分ほど色をつけたいので1から引いている。screenDepthを正規化。
                float edgeLine = 1 - saturate(_DepthFactor * screenDepth);
                // edgerLineを閾値として色を出力
                fixed4 finalColor = lerp(waveColor, _EdgeColor, edgeLine);

                return finalColor;
            }
            ENDCG
        }
    }
}
