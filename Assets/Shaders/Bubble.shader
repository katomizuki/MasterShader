Shader "Unlit/Bubble"
{
    Properties
    {
        [PowerSlider(0.1)]_F0("F0", Range(0,1)) = 0.02
        _RimLightIntensity("RimLight Intensity", Float) = 1.0
        _Color("Color",Color) = (1,1,1,1) 
        _MainTex("Texture", 2D) = "white"{}
        _DTex("D Texture", 2D) = "gray" {}
        _LTex("LE Texture2", 2D) = "gray" {}
        CubeMap("Cube Map", Cube) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/NoiseUtil/ClassicPerlinNoise2D.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float3 lightDir : TEXCOORD4;
                half fresnel : TEXCOORD5;
                half3 reflDir : TEXCOORD6;
            };

            sampler2D _MainTex;
            sampler2D _DTex;
            sampler2D _LETex;

            UNITY_DECLARE_TEXCUBE(_CubeMap);

            float _F0;
            float _RimLightIntensity;
            float4 _Color;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                // クリップ空間へ変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                o.tangent = v.tangent;
                // 引数新良たオブジェクトのカメラに対するベクトルを計算（視線ベクトル) オブジェクト空間でのベクトル
                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                // 引数に与えられた頂点の光源に対するオブジェクト空間でのベクトルを計算（正規化されてないのでする）
                o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
                // フレネル効果(視線ベクトルと法線ベクトルで出すことができる）1.0から減算するのは、フレネル効果が内積が1に近いほど、
                // 光沢が弱めになる。（球体でいう真ん中が弱くなり、外側に行くほど、反射が強まるため。
                o.fresnel = _F0 + (1.0h - _F0) * pow(1.0h - dot(o.viewDir, v.normal), 5.0);
                // reflectで反射ベクトルを算出してワールド空間上に変換。
                o.reflDir = mul(unity_ObjectToWorld, reflect(-o.viewDir, v.normal));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //要は構造色情報テクスチャを用意してどのテクスチャをフェッチするかを入射光が反射して光る光路差に基づいて決定するということ。
                // 光路差と言っても視線と光源どちらも考える必要がある。
                i.uv = pow((i.uv * 2.0) - 1.0, 2.0);
                // Noise値
                float d = perlinNoise((i.uv + _Time.xy * 0.1) * 3.0);
                float u, v;
                // 入射光からuを計算する
                {
                    // L * N
                    float ln = dot(i.lightDir, i.normal);
                    ln = (ln * 0.5) * d;
                    // L * T
                    float lt = dot(i.lightDir, i.tangent);
                    lt = ((lt + 1.0) * 0.5) * d;
                    u = tex2D(_LETex, float2(ln, lt)).x;
                }

                // 視線ベクトルからvを計算する
                {
                    // E * N
                    float en = dot(i.viewDir, i.normal);
                    en = ((1.0 - en) * 0.5 + 0.5) * d;
                    // E * T 
                    float et = dot(i.viewDir, i.tangent);
                    et = ((et + 1.0) * 0.5) * d;
                    v = tex2D(_LETex, float2(en,et)).x;
                }
// 法線とライト方向の内積拡散反射は出す。
                float2 uv = float2(u,v);
                float4 col = tex2D(_MainTex, uv);

                // 法線と光の方向ベクトルの内積を出す
                float NdotL = dot(i.normal, i.lightDir);
                //  反射ベクトル=> (2 * (ライトベクトルと法線ベクトルの近似値) * 法線) + ライトベクトルになる。
                // reflect(-lightDir, normal)とやっていることは同じ。
                float3 localRefDir = -i.lightDir + (2.0 * i.normal * NdotL);
                // 視線ベクトルと反射ベクトルで内積を出して、0を切り捨て、powで強くする=>鏡面反射
                float spec = pow(max(0, dot(i.viewDir, localRefDir)), 10);
                // 1 - 法線と視線方向の内積を出す
                float rimLight =  1.0 - dot(i.normal, i.viewDir);
                fixed4 cubeMap = UNITY_SAMPLE_TEXCUBE(_CubeMap, i.reflDir);
                cubeMap.a = i.fresnel;
                col *= cubeMap;
                col += rimLight * _RimLightIntensity;
                col += spec;
                return  col;
            }
            ENDCG
        }
    }
}
