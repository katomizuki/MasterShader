Shader "Unlit/TrialSShader2"
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

            #define PI 3.14159265359
            #include "UnityCG.cginc"
            #include "Common.cginc"
// 回転行列
            float2 rotate(float2 st, float angle)
            {
                float matri = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                st -= 0.5;
                st = mul(matri, st);
                st += 0.5;
                return st;
            }
// ランダム関数
            float rand(float2 st)
            {
              return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453); 
            }
            
            float box(float2 st, float2 size)
            {
                st = step(size, st) * step(size, 1.0 - st);
                return st.x * st.y;
            }
// 軌跡を残すメソッド
            float trail(float2 st, float n)
            {
                // 入ってきた ｘ軸をｎ個分割する(0 ~ 45)少数点含む
                float stxn = st.x * n;
                // sin(st.y) 0 ~ 1 サイン波を入れる。
                stxn *= sin(st.y);
                // sin(y座標 + 時間 + ランダム数(floorでｎますとしてくぎる))
                float size = sin(st.y + _Time.y + rand(floor(stxn)));
                
                // stxnを一つ一つのますとして扱いたいのでfrac() (0~0.999,,)が入る
                st = frac(stxn);
                //  四角形を作りたいので
                float boxst = box(st, size);
                return boxst;
            }
            
           

            fixed4 frag (v2f_img i) : SV_Target
            {
// アスペクト比を整える
                i.uv = screen_aspect(i.uv);
                // 45度回転させる
                i.uv = rotate(i.uv, PI / 4);
                //// 45
                float l1 = trail(i.uv, 100);
                float l2 = trail(i.uv, 200);
                float l3 = step(2, l1 + l2);
                
                return float4(l1, l3, l2, 1);
            }
            ENDCG
        }
    }
}
