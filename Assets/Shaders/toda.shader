Shader "Unlit/toda"
{
    Properties
    {
        _SquareNum("SquareNum",int) = 5
        [HDR] _WaterColor("WaterColor",Color) = (0.09, 0.89, 1, 1)
        _WaveSpeed("WaveSpeed", Range(1, 10)) = 1
        _FoamPower("FoamPower", Range(0, 1)) = 0.6
        _FoamColor("FoamColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags 
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha

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
                float4 vertex : SV_POSITION;
            };

            uniform sampler2D _CamaraDepthTexture;
            int _SquareNum;
            fixed4 _WaterColor;
            fixed4 _FoamColor;
            float _WaveSpeed;
            float _FoamPower;

            float2 rand2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 st = i.uv;
                st *= _SquareNum;
// マス目の小数点を切り捨て
                float2 ist = floor(st);
                // 小数点のみ
                float2 fst = frac(ist);

                float4 waveColor = 0;
                float m_dist = 100;

                // 自分自身含む周囲のマスを探索
                for(int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        // 周囲の1×1のエリア
                        float2 neighbor = float2(x, y);
                        // 点のxｙ座標
                        float2 p = 0.5 + 0.5 * sin(rand2(ist + neighbor) + _Time.x * _WaveSpeed);

                        // 点と処理対象のピクセルとの距離ベクトル
                        float2 diff = neighbor + p - fst;
                        m_dist = min(m_dist, length(diff));

                        waveColor = lerp(_WaterColor, _FoamColor,smoothstep(1 - _FoamPower, 1, m_dist));
                        
                    }
                }
                return waveColor;
            }
            ENDCG
        }
    }
}
