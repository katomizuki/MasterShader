Shader "Unlit/Marbel"
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
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                    dot(st, float2(269.5, 183.3)));
/// ら
                return frac(sin(st) * 43758.5453123);
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
// アスペクト比を調整

               i.uv = screen_aspect(i.uv);
               float2 st = i.uv;
               st *= 3;
// 各マスごとに制御したいのでfloorで正規化

               float2 ist = floor(st);
// 3 * 3 のパネルに分割する

               float2 fst = frac(st);
// 距離を宣言する（これを更新していく

               float distance = 5;

               for (int y = -1; y <= 1; y++)
                {
                for(int x = -1; x <= 1; x++)
                 {
// 二回for文を回すことで隣あるセルに入ったあるpを取ってきたい
                    float2 neighbor = float2(x, y);
// マスの起点を基準にした白点のxy座標
                    float2 p = 0.5 + 0.5 * sin(_Time.y + 6.2831 * random2(ist * neighbor));
// 白点とピクセルとの距離ベクトル
                    float2 diff = neighbor + p - fst;
// 一番距離の近い母点を調べる

                    distance = min(distance, distance * length(diff) * length(diff));
                 }
                }

                return float4(smoothstep(0.1, abs(0.3 - smoothstep(0, 0.03, distance)),1),
                      smoothstep(0.1, abs(0.9 - smoothstep(0, 0.13, distance)),1),
                      smoothstep(0.1, abs(0.7 - smoothstep(0, 0.07, distance)),1),
                      0);
            }
            ENDCG
        }
    }
}
