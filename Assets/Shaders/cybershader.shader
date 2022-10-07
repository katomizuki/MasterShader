Shader "Unlit/cybershader"
{
    Properties
    {
        [HDR] _MainColor("MainColor", Color) = (1,1,1,1)
        _RepeatFactor("RepeatFactor", Range(0, 10000)) = 50
        _DistanceInterpolation("DistanceInsterpolation", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
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
                float3 worldPos : WORLD_POS;
            };

            float4 _MainColor;
            float _RepeatFactor;
            float _DistanceInterpolation;

            float hex(float2 uv, float scale = 1)
            {
                float2 p = uv * scale;
                p.x *= 1.15;
                float isTwo = frac(floor(p.x) / 2.0) * 2.0;
                p.y += isTwo * 0.5;
                p = frac(p) - 0.5;
                p = abs(p);
                // 六角形タイルとして出力
                return abs(max(p.x * 1.5 + p.y, p.y * 2.0) - 1.0);
            }
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // カメラとオブジェクトの距離(長さ）の取得
                float cameraToObjLength = length(_WorldSpaceCameraPos - i.worldPos);
                // 六角形描画のUVを利用して補間値を計算
                float interpolation = hex(i.uv, _RepeatFactor);
                // lerpで塗り分ける。
                float3 finalColor = lerp(_MainColor, 0, interpolation);
                // 六角形描画のUVを利用してアルファを塗り分ける
                float alpha = lerp(1, 0, interpolation);
                // 1m以下　_DistanceInterpolationが0の時アルファが完全に0にならないのでMaxで切り取る
                alpha *= lerp(1, 0, max(cameraToObjLength, 1) * _DistanceInterpolation);
                clip(alpha);
                return float4(finalColor, alpha);
            }
            ENDCG
        }
    }
}
