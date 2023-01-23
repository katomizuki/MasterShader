Shader "Unlit/ToonWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SquareNum("SquareNum", int) = 5
        [HDR] _WaterColor("WaterColor", Color) = (0.09, 0.89, 1,1)
        _WaveSpeed("WaveSpeed", Range(1,10)) = 1
        _FoamPower("FoamPower", Range(0,1)) = 0.6
        _FoamColor("Foam Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "RandomUtil/RandomUtil.cginc"

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

            uniform sampler2D _CameraDepthTexture;
            int _SquareNum;
            fixed4 _WaterColor;
            fixed4 _FoamColor;
            float _WaveSpeed;
            float _FoamPower;

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
                float2 ist = floor(st);
                float2 fst = frac(st);

                float4 waveColor = 0;
                float m_dist = 100;

                for(int y = -1; y <= 1; y ++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 neighbor = float2(x, y);
                        // 点のx,y座標 この0.5は0 ~ 1に丸め込んでいる。
                        float2 p = 0.5 + 0.5 * sin(random2(ist + neighbor) + _Time.x * _WaveSpeed);
                        // 点と処理対象のピクセルとの距離ベクトル
                        float2 diff = (neighbor + p) - (0 + fst);
                        m_dist = min(m_dist, length(diff));
                        waveColor = lerp(_WaterColor, _FoamColor, smoothstep(1 - _FoamPower,1, m_dist));
                    }
                }
                return waveColor;
            }
            ENDCG
        }
    }
}
