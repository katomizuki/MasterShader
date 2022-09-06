Shader "Unlit/MetaMetaShader"
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

            // 回転行列で回転お決まりパターン
            float2 rotate(float2 st, float angle)
            {
                st -= 0.5;
                st = mul(float2x2(cos(angle), -sin(angle), sin(angle), cos(angle)), st);
                st += 0.5;
                return st;
            }
// 時間の経過によってx方向に1倍、y軸方向に時間かける * 3(スケーラー）のサイン波を作成し、これをOffset(移動幅）として　st(座標）にaddする（動かす）
            float2 move(float2 st, float offset)
            {
                float time = _Time.y;
                float xOffset = sin(offset + time);
                float yOffset = sin(offset + time * 3);
                return st + float2(sin(xOffset),sin(yOffset));
            }

            float hex(float2 st)
            {
  
                // 現在の座標の絶対値
                st = abs(st);
                // どちらがでかいかを調べる。ここがなぜ多角形になるのか？
                return max(st.x, max(st.x + st.y * 0.5, st.y));
            }
// 円を作る距離関数。0.5とstの距離を塗りつぶして円にする
          float circle(float2 st) { return distance(0.5, st); } 

            float meta_xx(float2 st)
            {
                //
              float d = hex(move(st, 0)) *
                  circle(move(st, 4)) *
                  circle(move(st, 8));
        // 時間によって区分を分ける
             float ft = frac(_Time.y * 2);
                // smoothstempで闢値をなめらかに変化させる
             float a = smoothstep(0.5, 0.75, ft) *
             (1 - smoothstep(0.75, 1.0, ft));
        
        return step(lerp(0.25, 1, a), abs(sin(d * 15)));
            }
            
            fixed4 frag (v2f_img i) : SV_Target
            {
                // アスペクト比の調整
                i.uv = screen_aspect(i.uv);
                // Timeに2(スケラー）をかけた数
                float time =_Time.y * 2;
                // 経過時間＊2によって座標を回転させる。回転させた座標を0.5から引くことで真ん中に原点がある状態にする。それの絶対値にすることで繰り返しを表示する
                float2 st = abs(0.5 - rotate(i.uv, time));
                // 元の座標がどれだけ中心から離れているかのベクトルの長さ
                float len = length(0.5 - i.uv);
                // 色付け
                float vinette = 1.2 - len;
                // lerpで線形補完
                return lerp(float4(0.9, 1, 0.04, 1), float4(0.3, 0.3, 0.01, 1), meta_xx(st)) * vinette;
            }
            ENDCG
        }
    }
}
