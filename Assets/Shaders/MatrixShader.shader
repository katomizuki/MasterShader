Shader "Unlit/MatrixShader"
{
    Properties
    {
        _Grid("Grid", range(1, 50)) = 30
        _SpeedMax("Speed Max", range(0, 30)) = 20
        _SpeedMin("Speed Min", range(0,10)) = 2
        _Density("Density", range(0,30)) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/NoiseUtil/SimplexNoise2D.cginc"
            float _Density;
            float _Grid;
            float _SpeedMax;
            float _SpeedMin;

            float noise(float x)
            {
                return frac(sin(x) * 43758.5453);
            }

             float texelValue(float2 ipos, float n){
                for(float i = 0.; i < 5.; i++){
                    for(float j = 0.; j < 3.; j++)
                    {
                        if (i == ipos.y && j == ipos.x ) {
                            return step(1., fmod(n, 2.));
                        }
                        n = ceil(n / 2.);
                    }
                }
                return 0.;
            }
// fpos 
            float char(float2 st, float n){
                    st.x = st.x * 2. - .5;
                    st.y = st.y * 1.2 - .1;
 
                    float2 ipos = floor(st * float2(3., 5.));

                // 浮動小数の剰余を求める
                    n = floor(fmod(n, 20. + _Density));
 
                    float digit = 0.0;
                   
                    if (n < 1. ) { digit = 9712.; }
                    else if (n < 2. ) { digit = 21158.0; }
                    else if (n < 3. ) { digit = 25231.0; }
                    else if (n < 4. ) { digit = 23187.0; }
                    else if (n < 5. ) { digit = 23498.0; }
                    else if (n < 6. ) { digit = 31702.0; }
                    else if (n < 7. ) { digit = 25202.0; }
                    else if (n < 8. ) { digit = 30163.0; }
                    else if (n < 9. ) { digit = 18928.0; }
                    else if (n < 10. ) { digit = 23531.0; }
                    else if (n < 11. ) { digit = 29128.0; }
                    else if (n < 12. ) { digit = 17493.0; }
                    else if (n < 13. ) { digit = 7774.0; }
                    else if (n < 14. ) { digit = 31141.0; }
                    else if (n < 15. ) { digit = 29264.0; }
                    else if (n < 16. ) { digit = 3641.0; }
                    else if (n < 17. ) { digit = 31315.0; }
                    else if (n < 18. ) { digit = 31406.0; }
                    else if (n < 19. ) { digit = 30864.0; }
                    else if (n < 20. ) { digit = 31208.0; }
                    else { digit = 1.0; }
 
                    float tex = texelValue(ipos, digit);
 
                    float2 borders = float2(1., 1.);
                    borders *= step(0., st) * step(0., 1. - st);
 
                    return step(.1, 1. - tex) * borders.x * borders.y;
            }

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

            fixed4 frag (v2f_img i) : SV_Target
            {
                // 格子Index
                float2 ipos = floor(i.uv * _Grid);
                // 0 ~ 1 
                float2 fpos = frac(i.uv * _Grid);

                // y 軸に動かしたいので格子単位で動かす。
                ipos.y += floor(_Time.y * max(_SpeedMin, _SpeedMax * noise(ipos.x)));
                // 文字に変換する文字列数字
                float charNum = simplexNoise2D(ipos);
                // val(0かNoise値）
                float val = char(fpos, (20 + _Density) * charNum);
                // valで
                return fixed4(0, val, 0, 1.0);
            }
            ENDCG
        }
    }
}
