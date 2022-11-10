Shader "Unlit/gradationPoints"
{
    Properties
    {
        _StartColor("StartColor",Color) = (1,1,1,1)
        _EndColor("EndColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 texcoord : TEXCOORD0;
            };

            float4 _StartColor;
            float4 _EndColor;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 startColor = float4(_StartColor.r, _StartColor.g, _StartColor.b, _StartColor.a);
               float4 endColor = float4(_EndColor.r, _EndColor.r, _EndColor.g, _EndColor.a);
                return lerp(startColor, endColor, i.texcoord.y * 0.2f);
            }
            ENDCG
        }
    }
}
