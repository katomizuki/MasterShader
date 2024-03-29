Shader "Unlit/HadouShader"
{
    Properties
    {
        _S2("PhaseVelocity", Range(0.0, 0.5)) = 0.2
        _Attenuation("Attenuation", Range(0.0, 1.0)) = 0.999
        _DeltaUV("Delta UV", Float) = 0.1
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag

            #include "UnityCustomRenderTexture.cginc"

            half _S2;
            half _Attenuation;
            float _DeltaUV;
            sampler2D _MainTex;

            fixed4 frag (v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.globalTexcoord;
                // 1pxあたりの単位
                float du = 1.0 / _CustomRenderTextureWidth;
                float dv = 1.0 / _CustomRenderTextureHeight;

                // 現在のテクセルをフェッチ
                float2 duv = float2(du, dv) * _DeltaUV;

                // 波動方程式
                //  //h(t + 1) = 2h + c(h(x + 1) + h(x - 1) + h(y + 1) + h(y - 1) - 4h) - h(t - 1)
                // 波の高さを表す
                // R,Gをそれぞれ高さとして使用

                float c = tex2D(_SelfTexture2D, uv);
                float k = (2.0 * c.r) - c.g;
                 float p = (k + _S2 * ( //_S2は係数 位相の変化する速度
                    tex2D(_SelfTexture2D, uv + duv.x).r +
                    tex2D(_SelfTexture2D, uv - duv.x).r +
                    tex2D(_SelfTexture2D, uv + duv.y).r +
                    tex2D(_SelfTexture2D, uv - duv.y).r - 4.0 * c.r)
                ) * _Attenuation;
                return float4(p, c.r, 0, 0);
            }
            ENDCG
        }
    }
}
