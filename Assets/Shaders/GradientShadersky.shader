Shader "Unlit/GradientShadersky"
{
    Properties
    {
        _TopColor("TopColor",Color) = (0, 0, 0, 0)
        _UnderColor("UnderColor", Color) = (0, 0, 0, 0)
        _ColorBorder("ColorBorder", Range(0,3)) = 0.5
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
            "Queue"= "Background"
            "PreviewType"="SkyBox"
            }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 _UnderColor;
            float4 _TopColor;
            float _ColorBorder;
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f  
            {
                float4 pos : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.worldPos = v.vertex.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 描画したいピクセルのワールド座標を正規化
                float3 dir = normalize(i.worldPos);
                // ラジアンを算出する
                // atan2(x, y) 直行座標の角度をラジアンで返す
                float2 rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                float2 uv = rad / float2(2.0 * UNITY_PI, UNITY_PI / 2);

                return lerp(_UnderColor, _TopColor, uv.y + _ColorBorder);
            }
            ENDCG
        }
    }
}
