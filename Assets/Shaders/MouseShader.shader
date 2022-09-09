Shader "Unlit/MouseShader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct v2f
            {
                float3 worldPos : WORLD_POS;
                float4 vertex : SV_POSITION;
            };

// C#から流れてくる
            float4 _MousePosition;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 描画したいピクセルのワールド座標を計算
                //unity_ObjectToWorld->モデル行列 
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ベースカラー　白
                float4 baseColor = (1,1,1,1);
                // マウスからでたRayとオブジェクトの衝突範囲と描画しようとしているピクセルのワールド座標を求める
                float dist = distance(_MousePosition, i.worldPos);
                // 求めた距離が任意の距離以下なら描画しようとしているピクセルの色を変える
                if(dist < 0.1)
                {
                    // 赤色を乗算
                    baseColor *= float4(1,0,0,0);
                }
                return baseColor;
            }
            ENDCG
        }
    }
}
