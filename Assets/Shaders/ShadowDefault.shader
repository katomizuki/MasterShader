Shader "Unlit/ShadowDefault"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
            "LightMode"="ForwardBase" 
        }
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlights

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 diff : COLOR0;
                // posと決め内になっているので注意
                float4 pos : SV_POSITION;
                // Shadow用のfloat4 型を定義する。TEXCOORD0はすでに使用されているので1を入れてあげる。
                SHADOW_COORDS(1)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half NdotL = saturate(dot(worldNormal, _WorldSpaceLightPos0.xyz));
                o.diff = NdotL * _LightColor0;
                /// SHADOW_COORDSに定義した _ShadowCoordにスクリーンスペースの座標を入れている
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // シャドウマップのテクセルを反映する。
                fixed4 shadow = SHADOW_ATTENUATION(i);
                return col * i.diff * shadow;
            }
            ENDCG
        }
        
        Pass {
            Tags { "LightMode"="ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
               V2F_SHADOW_CASTER; 
            };

            v2f vert (appdata v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
            }
    }
}
