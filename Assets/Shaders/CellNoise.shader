Shader "Unlit/CellNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float2 random2(float st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

        float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
// スクリーン座標による正規化 // 
            i.uv = screen_aspect(i.uv);
        
            float2 st = i.uv;
            st *= 4.0;
// 各マスを個別に制御するためにfloorを使う //  
            float2 ist = floor(st);
// stの数だけUV座標を分割する // 
            float2 fst = frac(st);

            float distance = 5;
//自身含む周囲のマスを探索
//自身のマスは(0,0)

            for (int y = -1; y <= 1; y++)
            for (int x = -1; x <= 1; x++)
            {
 //マスの起点
            float2 neighbor = float2(x, y);
////マスの起点を基準にした白点のxy座標  //
            float2 p = 0.5 + 0.5 * sin(_Time.y + 6.2831 * random2(ist + neighbor));
    //白点と処理対象のピクセルとの距離ベクトル
            float2 diff = neighbor + p - fst;
  //白点との距離が短くなれば更新
            distance = min(distance, length(diff));
            }
            float4 color = distance * 0.5;
            return float4(color.x, color.y, 0.4, color.z);
            }
            ENDCG
        }
    }
}
