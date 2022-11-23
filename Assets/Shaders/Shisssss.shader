Shader "ParallaxMap" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        [Normal] _NormalMap ("Normal map", 2D) = "bump" {}
        _HeightMap ("HeightMap map", 2D) = "white" {}
        _Shininess ("Shininess", Range(0.0, 1.0)) = 0.078125
        _HeightFactor ("Height Factor", Range(0.0, 0.1)) = 0.02
    }
    SubShader {

        Tags { "Queue"="Geometry" "RenderType"="Opaque"}

        Pass {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
           #include "UnityCG.cginc"

           #pragma vertex vert
           #pragma fragment frag

            float4 _LightColor0;
            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _HeightMap;
            half _Shininess;
            half _HeightFactor;

            struct appdata {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(appdata v) {
                v2f o;
// MVP
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = v.texcoord.xy;
                TANGENT_SPACE_ROTATION;
                // 接空間に変換
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
                
                return o;
            }

            float4 frag(v2f i) : COLOR {
                // 正規化
                i.lightDir = normalize(i.lightDir);
                i.viewDir = normalize(i.viewDir);
                // ハーフベクトル
                half3 halfDir = normalize(i.lightDir + i.viewDir);

                // ハイトマップをサンプリング
                fixed4 height = tex2D(_HeightMap, i.uv);
                // uv座標に(視線ベクトル ×　高さ値 * 調整値)を加算(本来のサンプリング値とはずらすことで)
                // 見えない部分が表現できる
                i.uv += i.viewDir.xy * height.r * _HeightFactor;
                fixed4 tex = tex2D(_MainTex, i.uv);
                // -1~1法線ベクトル
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                // 拡散
                fixed4 diff = saturate(dot(normal, i.lightDir)) * _LightColor0;
                // 鏡面 
                half3 spec = pow(max(0, dot(normal, halfDir)), _Shininess * 128.0) * _LightColor0.rgb;

                fixed4 color;
                color.rgb  = tex.rgb * diff + spec;
                return color;
            }

            ENDCG
        }

    }
    FallBack "Diffuse"
}