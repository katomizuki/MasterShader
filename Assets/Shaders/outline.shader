Shader "Unlit/outline"
{
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "LightMode"="ForwardBase" 
            }
        LOD 200

        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                 // 法線ベクトルにモデルを膨らませる
                v.vertex += float4(0.04f * v.normal, 0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(0.1f, 0.1f, 0.1f, 1);
                return col;
            }
            ENDCG
        }
        Pass {
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSTION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : COLOR {
               // dot で-1~1を返し0でmaxで負の値を切り取る
                half nl = max(0, dot(_WorldSpaceLightPos0.xyz, i.normal));
                if (nl <= 0.01f) nl = 0.1f;
                else if (nl <= 0.3f) nl = 0.3;
                else nl = 1.0f;
                fixed4 col = fixed4 (nl, nl, nl, 1);
                return  col;
            }
           ENDCG 
            }
    }
}
