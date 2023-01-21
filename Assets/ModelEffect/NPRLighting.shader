Shader "Unlit/NPRLighting"
{
    // 複数のライトのライティングをしたい場合はシェーダーのパスを複数作る必要がある。
    // Directional Lightバージョン
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpecularGloss("Specular Gloss", float) = 50.0
        _AmbientColor("Ambient Color", Color) = (0.3,0.3, 0.3,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            Blend One Zero
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SpecularGloss;
            half4 _AmbientColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldDir(v.normal);
                // カメラポジション - ワールド座標を引くことでサーフェイス表面からカメラ方向
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ライトベクトル
                float3 L =_WorldSpaceLightPos0.xyz;
                // 反射ベクトル
                float3 R = reflect(-L, i.normal);

                //　テキスチャマッピング
                fixed4 texColor = tex2D(_MainTex,i.uv);

                // 拡散反射
                float diffuse = saturate(dot(i.normal, L));

                // 鏡面反射
                float specular = pow(saturate(dot(i.viewDir, R)), _SpecularGloss);

                return ((diffuse + specular) * _LightColor0 + _AmbientColor) * texColor;
            }
            ENDCG
        }
        // PointLightでの実装。 点光源の場合減衰を考えたい
        Pass {
            // PointLightの場合はForwardAddで宣言しLightColor0でPointLightの色を取得する。
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One // 加算ブランド
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // UNITY_LIGHT_ATTENUATIONを利用するためにマルチコンパイル宣言 
            #pragma multi_compile_fwdadd_fullshadows
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SpecularGloss;
            half4 _AmbientColor;

            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                //　光の減衰を取得できる。
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

                float3 L = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                float3 R = reflect(-L, i.normal);

                fixed4 texColor = tex2D(_MainTex, i.uv);

                float diffuse = saturate(dot(i.normal, L));

                float specular = pow(dot(i.viewDir, R),_SpecularGloss);

                return (diffuse + specular) * texColor * _LightColor0 * attenuation;
            }
            ENDCG
        }
    }
}
