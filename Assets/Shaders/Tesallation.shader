Shader "Unlit/Tesallation"
{
    Properties
    {
        _Color( "Color",color) = (1,1,1,0)
        _MainTex("Base RGB", 2D) = "white" {}
        _DispTex("Disp Texture",2D) = "gray" {}
        _MinDist("Min Distance",Range(0.1, 50)) = 10
        _MaxDist("Max Distance",Range(0.1,50)) = 10
        _Tesslation("Tessellation", Range(1, 50)) = 10
        _Displacement("Displacement", Range(0, 1.0)) = 0.3
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma hull hull
            #pragma domain domain

            #include "UnityCG.cginc"
            // ビルトインシェーダーをインストール
            #include "Tessellation.cginc"
            // 定数を定義
            #define INPUT_PATCH_SIZE 3
            #define OUTPUT_PATCH_SIZE 3

            float _TessFactor;
            float _Displacement;
            float _MinDist;
            float _MaxDist;
            sampler2D _DispTex;
            sampler2D _MainTex;
            fixed4 _Color;
// GPU->頂点シェーダー
            struct appdata
            {
                float3 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };
// 頂点シェーダー->ハルシェーダー
            struct HsInput
            {
               float4 position : POS;
                float3 normal : NORMAL;
                float2 texCoord : TEXCOORD;
            };
// ハルシェーダーからテッセレーター経由でドメインシェーダーに渡す構造体
            struct HsControlPointOutput
            {
                float3 position : POS;
                float3 normal : NORMAL;
                float2 texCoord : TEXCOORD;
            };
// ドメインシェーダーからフラグメントシェーダーに渡す構造体
            struct HsConstantOutput
            {
               float tessFactor[3] : SV_TessFactor;
                float insideTessFactor : SV_InsideTessFactor;
            };
// ドメインシェーダーからフラグメントシェーダーに渡す構造体
            struct DsOutput
            {
               float4 position : SV_Position;
                float2 texCoord : TEXCOORD0;
            };

            // 頂点シェーダー
            HsInput vert (appdata v)
            {
                HsInput o;
                o.position = float4(v.vertex, 1.0);
                o.normal = v.normal;
                o.texCoord = v.texcoord;
                return o;
            }
// コントロールポイント=> 頂点分割で使う制御点
            // パッチ ポリゴン分割処理を行う際にコントロールポイントの集合
            // ハルシェーダ 
            // パッチに対してコントロールポイントを割り当てる
            // コントロールポイントごとに1回実行
            [domain("tri")] //　分割するポリゴンの形状を指定 
            [partitioning("integer")] // どうポリゴンを分割するのかをして
            [outputtopology("triangle_cw")] // 出力された頂点が形成する形状を指定
            [patchconstantfunc("hullConst")] // patch-constant-functionの指定
            [outputcontrolpoints(OUTPUT_PATCH_SIZE)] // 出力コントロールポイントの数
            HsControlPointOutput hull(InputPatch<HsInput, INPUT_PATCH_SIZE> i,uint id : SV_OutputControlPointID)
            {
                HsControlPointOutput o = (HsControlPointOutput)0;
                // 頂点シェーダーに対して、コントロールポイントを割り当て
                o.position - i[id].position.xyz;
                o.normal = i[id].normal;
                o.texCoord = i[id].texCoord;
                return o;
            }
    // patch constant func
            // どの程度頂点を分割するかを決める係数を詰め込んでテッセレーターに渡す関数のこと
            // パッチごとに一回実行される
            HsConstantOutput hullConst(InputPatch<HsInput, INPUT_PATCH_SIZE> i)
            {
                HsConstantOutput o = (HsConstantOutput)0;
                float4 p0 = i[0].position;
                float4 p1 = i[1].position;
                float4 p2 = i[2].position;
                //頂点からカメラまでの距離を計算しテッセレーション係数
                float4 tessFactor = UnityDistanceBasedTess(p0, p1,p2, _MinDist, _MaxDist,_TessFactor);
                o.tessFactor[0] = tessFactor.x;
                o.tessFactor[1] = tessFactor.y;
                o.tessFactor[2] = tessFactor.z;
                o.insideTessFactor = tessFactor.w;
                return o;
            }
// ドメインシェーダー
            // てっせれーたーから出てきた分割位置で頂点を計算し出力するのが仕事
            [domain("tri")] // 分割に利用する形状を指定
            DsOutput domain(HsConstantOutput hsConst,
                const OutputPatch<HsControlPointOutput, INPUT_PATCH_SIZE> i,
                float3 bary : SV_DomainLocation)
            {
                DsOutput o = (DsOutput)0;
                // 新しく出力する各頂点の座標を計算
                float3 f3Position =
                    bary.x * i[0].position +
                    bary.y * i[1].position +
                    bary.z * i[2].position;

                //新しく出力する各頂点の法線を計算
                float3 f3Normal = normalize(
                    bary.x * i[0].normal +
                    bary.y * i[1].normal +
                    bary.z * i[2].normal);

                //新しく出力する各頂点のUV座標を計算
                o.texCoord =
                    bary.x * i[0].texCoord +
                    bary.y * i[1].texCoord +
                    bary.z * i[2].texCoord;

                //tex2Dlodはフラグメントシェーダー以外の箇所でもテクスチャをサンプリングできる関数
                //ここでrだけ利用することで波紋の高さに応じて頂点の変位を操作できる！すごい！
                float disp = tex2Dlod(_DispTex, float4(o.texCoord, 0, 0)).r * _Displacement;
                f3Position.xyz += f3Normal * disp;

                o.position = UnityObjectToClipPos(float4(f3Position.xyz, 1.0));

                return o;
            }

            fixed4 frag (DsOutput i) : SV_Target
            {
                return tex2D(_MainTex, i.texCoord) * _Color;
            }
            ENDCG
        }
    }
}
