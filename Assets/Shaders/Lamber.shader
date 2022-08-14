Shader "Sample/Lambert"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM

            #pragma vertex   vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            float4 _MainColor;

            v2f vert(appdata_base v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 法線を正規化して単位ベクトルにする
                float3 normal = normalize(i.normal);
                // 光源ベクトルを正規化して単位ベクトルにする//
                float3 light  = normalize(_WorldSpaceLightPos0.xyz);
                // dotで内積を出す cosを求められたので(-1 ~1 )saturateで0 ~ 1にClampする。
                float diffuse = saturate(dot(normal, light));

                return diffuse * _MainColor;
            }

            ENDCG
        }
    }
}