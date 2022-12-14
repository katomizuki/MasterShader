Shader "Unlit/ColorShader"
{
    Properties
    {
        _MainColor("MainColor",Color) = (1,1,1,1)
        _ShadowColor("ShadowColor", Color) = (0,0,0,1)
        _ShadowTex("ShadowTex", 2D) = "white" {}
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0.6
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            half4 _MainColor;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return half4(_MainColor);
            }
            ENDCG
        }
        Pass 
        {

            Tags 
            {
                "Queue"="geometry"
                "LightMode"="ForwardBase"   
            }
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #include "AutoLight.cginc"

            sampler2D _ShadowTex;
            float4 _ShadowTex_ST;
            float4 _ShadowColor;
            float _ShadowIntensity;

            float _ShadowDistance;

            struct appdata 
            {
               float4 vertex : POSITION;
                float2 shadow_uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 shadow_uv: TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 wolrdPos : WOLRD_POS;
                SHADOW_COORDS(1)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW(o);
                // タイリングとオフセットの処理
                o.shadow_uv = TRANSFORM_TEX(v.shadow_uv,_ShadowTex);
                // 法線方向のベクトル
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.wolrdPos = mul(unity_ObjectToWorld,v.vertex).xyz;
            }

            float4 frag(v2f i) : COLOR
            {
                // カメラとオブジェクトの距離（長さ）を取得
                // WorldSpaceCamerapos カメラの位置
                float cameraToObjLength = clamp(length(_WorldSpaceCameraPos - i.wolrdPos),0, _ShadowDistance);
                // ライトベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
               // ワールド座標系の法線を正規化
               float3 N = normalize(i.worldNormal);
                // 内積の結果が0以上なら1
                float front = step(0, dot(N, L));
                // 影の場合0,それ以外は1
                float attenuation = SHADOW_ATTENUATION(i);
                // 影の減衰率
                float fade = 1 - pow(cameraToObjLength / _ShadowDistance, _ShadowDistance);
                // 影の色(ここで色をつけている）
                float3 shadowColor = tex2D(_ShadowTex, i.shadow_uv) * _ShadowColor;
                // 影の場所とそれ以外の場所の塗り分け
                float4 finalColor = float4(shadowColor, (1 - attenuation) * _ShadowIntensity);
                return finalColor;
            }
            
            ENDCG
        }
    }
}
