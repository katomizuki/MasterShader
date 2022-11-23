Shader "Unlit/occ"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HeightMap("HeightMap",2D) = "white" {}
        _HeightScale("Height", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MaiinTex;
            sampler2D _HeightMap;
            float _HeightScale;
            
            struct appdata
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 position : NORMAL;
                float3 objectViewDir : TEXCOORD1;
                float3 objectPos : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.objectPos = mul(unity_ObjectToWorld, v.position);
                o.normal = v.normal;
                o.uv = v.uv;
                o.objectViewDir = o.objectPos - _WorldSpaceCameraPos.xyz;
                o.position = mul(UNITY_MATRIX_VP, o.objectPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // uv座標
                float2 uv = i.uv;
                // 
                float2 uvStart = i.uv;
                // レイベクトルを正規化
                float3 rayDir = normalize(i.objectViewDir);
                // ワールド座標
                float3 rayPos = i.objectPos;
                // レイ
                float3 rayPosStart = i.objectPos;
                float rayHeight = 0.0;
                float objHeight = -_HeightScale; // (-1 ~ 0)
                const int HeightSamples = 32;
                const float HeightPerSample = 1.0 / HeightSamples;
                // 
                float rayScale = (-_HeightScale / rayDir.y); // 何回進めが底に衝突するかどうか？
                // rayStep = 一回の進む距離 前回とはちあｇHeightPerSampleというレイを進める逆数をかける。
                float3 rayStep = rayDir * rayScale * HeightPerSample; // rayDir(一回分進む距離）* rayScale(何回進めば底に衝突するかどうか）　＊
                // rayDirとrayScaleでレイ全体の長さを求めてHeightPersampleをかけることで一回のレイでどれくらい進むかを計算できる。
                for (int i = 0; i < HeightSamples && objHeight < rayHeight; ++i)
                {
                    // 32回以内か objHeight < rayHeight(更新される）になった時に衝突
                    // レイの座標を算出したrayStepに足していく
                    rayPos += rayStep;
                    // オブジェクトのuv座標にrayStepでずらした座標（rayPos)を加算
                    // あくまで足すのは差分（どれくらいずらすか）なのでrayPosStartと減算する必要がある。
                    uv = uvStart + rayPos.xz - rayPosStart.xz;
                    // ヘイトマップから高さを取ってくる(0~1)
                    objHeight = tex2D(_HeightMap, uv).r;
                    // -HeightScale ~ 0に変換する objheight >= rayHeightになった時は衝突したということだから
                    // for文を抜けて、その時点でのずらされたuv座標のMaintexを取ってきてあげる。
                    objHeight = objHeight * _HeightScale - _HeightScale;
                    // 現在のレイの高さを更新する。
                    rayHeight = rayPos.y;
                }

                // この状態だとのめり込んだレイを考慮できてないので一個前のrayStepに戻って補完する
                float2 nextObjPoint = uv;
                // 一個前のraStepのuv座標
                float2 prevObjPoint = uv - rayStep.xz;
                float nextHeight = objHeight; // のめり込んだ時点でのオブジェクトのハイト
                // tex2Dで一個前のprevハイトを取ってきて それを-HeightScale ~ 0に変換する
                float prevHeight = tex2D(_HeightMap, prevObjPoint).r * _HeightScale - _HeightScale;
                // rayHeightのみ減算
                nextHeight -= rayHeight;
                // rayHeightからレイステップ一回分を引く
                prevHeight -= rayHeight - rayStep.y;
// nextHeightのpreveHeightの差分でnextHeighを
                /// nextheightとprevHeightの2点間の高さの差を求めて、その差分でnextHeightを割れば閾値を出せる。
                float weight = nextHeight / (nextHeight - prevHeight);
                // 衝突したuv座標とその一個前のuv座標を
                uv = lerp(nextObjPoint, prevObjPoint, weight);
                return tex2D(_MaiinTex, uv);
            }
            ENDCG
        }
    }
}
