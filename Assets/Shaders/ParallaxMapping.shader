Shader "Unlit/ParallaxMapping"
{
    Properties
    {
        _MainColor("MainColor",Color) = (1,1,1,1)
        _Reflection("Reflection", Range(0, 10)) = 1
        _Specular("Specular", Range(0, 10)) = 1
        _HeightFactor("Height", Range(0.0, 0.1)) = 0.02
        _NormalMap("Normal Map", 2D) = "bump" {}
        _HeightMap("Height Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }

        Pass
        {
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
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            float4 _MainColor;
            float _Reflection;
            float _Specular;
            float _HeightFactor;
            sampler2D _NormalMap;
            sampler2D _HeightMap;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // 宣言することで接空間上のものに変換するための行列
                TANGENT_SPACE_ROTATION;
                // ObjSpaceLightDirで変形する
                o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
                // ObjSpaceViewDirで視線ベクトルを接空間上へ変換して正規化
                o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ヘイトマッピングをずらす
                float4 height = tex2D(_HeightMap, i.uv);
                
                i.uv += i.viewDir.xy * height.r * _HeightFactor;
                // ノーマルマップから法線を取得
                float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                // ライトベクトルと法線ベクトルから反射ベクトルを計算
                float3 refVec = reflect(-i.lightDir, normal);
                 // 視線ベクトルと反射ベクトルの内積を計算
                float dotVR = dot(refVec, i.viewDir);
                // 0以下は利用しないように内積の値を再計算
                dotVR = max(0, dotVR);
                dotVR = pow(dotVR, _Reflection);
                // スペキュラー
                float3 specular = _LightColor0.xyz * dotVR * _Specular;
                // 内積を補間値として塗り分け
                float4 finalColor = _MainColor + float4(specular, 1);
                return finalColor;
            }
            ENDCG
        }
    }
}
// 視差マッピング物体の凹凸による視界の変化をメッシュの変形を使わず、疑似的に実現できる。
// 視線に応じてUVを変化させるだけで実現できる。
