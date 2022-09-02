Shader "Unlit/SampleShadeer"
{
    Properties
    {
        _RedValue("Red Value", float) = 0.5
        _GreenValue("Green Value", float) = 0.5
        _BlueValue("Blue Value", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
// 透明度を計算させる SrcAlapha->フラグメントシェーダーから出力されたa値
// OneMinusSrcAlpha->1 - フレグメントシェーダーから出力されたa値

        Blend SrcAlpha OneMinusSrcAlpha

    

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float _RedValue;
            float _GreenValue;
            float _BlueValue;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return float4(_RedValue, _GreenValue, _BlueValue, 1);
            }
            ENDCG
        }
    }
}
