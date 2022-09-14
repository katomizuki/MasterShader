Shader "Unlit/lllll"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"

            #define PI 3.141592
// ランダム変数
            float rand(float2 st)
            {
               return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453); 
            }
// 回転行列をかけて回転させる
            float2 rotate(float2 st, float angle)
            {
                float2x2 mat = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                st -= 0.5;
                st = mul(mat, st);
                st += 0.5;
                return st;
            }
// sizeを指定して四角形を作成する
            float box(float2 st, float size)
            {
                st = step(size, st) * step(size, 1 - st);
                return st.x * st.y;
            }
// 格子を作成
            float lattice(float2 st, float n)
            {
                // n * n の格子を作成
                float2 ist = floor(st * n);
                // 小数点を切り出してそれぞれ0 ~ 1での値に正規化
                float2 fst = frac(st * n);
                // 
                float x = (ist.x + ist.y) / n;
                // sizeを指定して x はスケーラ- -1 ~ 1がはいる
                float sinH = sin(x + _Time.y + rand(ist));
                // 0 ~ 1にsizeを正規化する
                float size = (1 + sinH) * 0.5;
                // fstので0 ~ 1で正規化した座標にそれぞれ四角形を作成する
                return box(fst, size) * size * 100;
            }
            fixed4 frag (v2f_img i) : SV_Target
            {
                // アスペクト比を調整
               i.uv = screen_aspect(i.uv);
                // 90度回転させる
                i.uv = rotate(i.uv, -PI / 4);
                // 8 * 8　の格子を作成
                float l1 = lattice(i.uv, 8);
                // 16 * 16 の格子を作成
                float l2 = lattice(i.uv, 16);
                return l1 + l2;
            }
            ENDCG
        }
    }
}
