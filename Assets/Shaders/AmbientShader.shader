Shader "Unlit/AmbientShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
    }
    
    SubShader
    {
        Tags
            {
                "LightMode" = "ForwardBase"
            }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
  

            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            float4 _MainColor;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
// 法線を正規化
                float3 normal = normalize(i.normal);
// 光線の情報を取ってきて正規化
                float3 light  = normalize(_WorldSpaceLightPos0.xyz);

                float  diffuse = saturate(dot(normal, light));
                float4 ambient = unity_AmbientSky;
//「拡散反射光 * オブジェクトの色 * 照射する光の
//色」
// 拡散反射の色 + 環境光を反射した色」

                return diffuse * _MainColor * _LightColor0
                     + ambient * _MainColor;

                // float3 ambient = ShadeSH9(half4(normal, 1));
                // 
                // fixed4 color = diffuse * _MainColor * _LightColor0;
                //        color.rgb += ambient * _MainColor;
                // 
                // return color;
            }
            ENDCG
        }
    }
}
