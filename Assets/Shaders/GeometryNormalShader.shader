Shader "Unlit/GeometryNormalShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _PositionFactor("Position Factor", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom // ジオメトリシェーダー

            #include "UnityCG.cginc"

            fixed4 _Color;
            float _PositionFactor;

            // 頂点シェーダーに渡ってくる頂点データ
            struct appdata
            {
                float4 vertex : POSITION;
            };
            // ジオメトリシェーダーからフラグメントシェーダーに渡すシェーダー
            struct g2f 
            {
               float4 vertex : SV_POSITION; 
            };
            

            // ただ返すだけ
            appdata vert (appdata v)
            {
                return v;
            }
// inputで文字通り頂点シェーダーからの入力 streamは参照渡しTriangleStream(三角形メッシュ）で三角面を出力する 
            [maxvertexcount(3)] // 出力する頂点の最大数(隣接する頂点） 0, 1, 2
            void geom(triangle appdata input[3], inout TriangleStream<g2f> stream)
            {
                // 法線の計算
                // 入ってきた頂点の隣接するの差を求めてベクトルを出す
                float3 vec1 = input[1].vertex - input[0].vertex;
                // 入ってきた頂点の隣接する差を求めてベクトルを出す
                float3 vec2 = input[2].vertex - input[0].vertex;
                // ベクトルの外積をcrossで出して正規化すれば出せる。
                float3 normal = normalize(cross(vec1, vec2));
                // 繰り返し処理 コンパイル後のコードの記述を変えてくれる予約語　unrollをつけることでメモリサイズが大きくなるが
                [unroll] //コンパイル方法を指定している。　forをつけると[unroll]を指定すると良さそう
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    // 法線ベクトルにそって頂点移動
                    v.vertex.xyz += normal * (sin(_Time.w) + 0.5) * _PositionFactor;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    // streamを参照すると
                    stream.Append(o);
                }
            }

            // ジオメトリシェーダー
            fixed4 frag (g2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
