Shader "Unlit/Outlineeee"
{
    Properties
    {
        _Color("MainColor",Color) = (0,0,0,0)
        _OutlineWidth("Outline width", Range(0.005, 0.03)) = 0.01
        [HDR] _OutlineColor("Outline Color", Color) = (0,0,0,1)
        [Toggle(USE_VERTEX_EXPANSION)] _UseVertexExpansion("Use vertex for outline", int) = 0
    }
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
                float4 pos : SV_POSITION;
            };
            
            half4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                return _Color;
            }
            ENDCG
        }
        
        Pass {
    Cull Front
    CGPROGRAM

    #pragma vertex vert
    #pragma fragment frag
    #pragma shader_feature USE_VERTEX_EXPANSION
    #include "UnityCG.cginc"

    float _OutlineWidth;
    float4 _OutlineColor;

    struct appdata 
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
    };

    struct v2f 
    {
        float4 pos : SV_POSITION;
    };

    v2f vert(appdata v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        float3 n = 0;
        #ifdef USE_VERTEX_EXPANSION
        float3 dir = normalize(v.vertex.xyz);
        // モデルビュー行列でビュー空間に変換。その逆行列なので、モデル座標空間に戻せる。その転置行列で法線を修正する必要がある。
        // 逆転置行列なのは法線方向を正しく修正したいため。 モデルビュー行列なのでビュー空間には変換される。
        // https://qiita.com/ktanoooo/items/7da443e7bc38f7ff6734
        // https://tips.hecomi.com/entry/2015/04/25/214050
        n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, dir));
        #else
          n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
        #endif
        // z方向に拡大する意味はないのでxy方向だけ入れてoffsetとして使用する。 名前の通りビュー座標系をプロジェクション座標系に変換する。
        const float2 offset = TransformViewToProjection(n.xy);
        o.pos.xy += offset * _OutlineWidth;
        return o;
    }


    fixed4 frag(v2f i) : SV_Target
    {
        return _OutlineColor;
    }
    ENDCG
            }
    }
}
