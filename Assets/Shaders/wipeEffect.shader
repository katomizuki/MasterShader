Shader "Unlit/wipeEffect"
{
    Properties
    {
        _Radius("Radius", Range(0, 2)) = 2
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _Radius;
            sampler2D _MainTex;

            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                // 原点を中心に移動
                i.uv -= fixed2(0.5f, 0.5f);
                // UNITY_NEAR_CLIP_VALUE->カメラのクリップ空間を描画できる最短距離のこと ProjectionParams clipping planeの値が格納されている
                float4 projectionSpaceUpperRight = float4(1,1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y);
                // カメラのプロジェクション行列の逆行列
                float4 viewSpaceUpperRight = mul(unity_CameraInvProjection, projectionSpaceUpperRight);
                // アスペクト比を算出して、x座標にかける。
                i.uv.x *= viewSpaceUpperRight.x / viewSpaceUpperRight.y;
                // 今みているuvの原点との距離を求める
                if(distance(i.uv, fixed2(0,0)) < _Radius)
                {
                    return color;
                }
                return fixed4(0,0,0,1);
            }
            ENDCG
        }
    }
}
