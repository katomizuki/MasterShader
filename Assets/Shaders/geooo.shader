Shader "Unlit/geooo"
{
    Properties
    {
        _BGColor("Background Color", Color) = (0.05, 0.9, 1, 1)
        _SunColor("Color", Color) = (1, 0.8, 0.5, 0)
        _SunDir("Sun Direction",Vector) = (0, 0.5, 1, 0)
        _SunStrength("Sun Strengh", Range(0, 200)) = 30
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Background" // 背景面に描画する
            "Queue" = "Background" // 背景なのでBackGround
            "PreviewType" = "SkyBox" 
        }
        
        ZWrite Off // 深度情報を書き込み不要。

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            fixed3 _BGColor;
            fixed3 _SunColor;
            float3 _SunDir;
            float _SunStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 uv : TEXCOOR0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = normalize(_SunDir); // 太陽の位置ベクトルの正規化
                // それぞれのベクトルをノーマライズし単位ベクトルにしておく必要がある。
                float angle = dot(dir, i.uv); // 太陽の位置ベクトルと描画されるピクセルの位置ベクトルの内積を出す
// ポイントの法線、ライトまでのベクトルの内積を出してどれくらいの角度で反射するか確かめる。
                // angleがマイナスにならないようにmax0以上にする。それを光の強さで累乗して
                fixed3 c = _BGColor + _SunColor * pow(max(0, angle), _SunStrength);
                return fixed4(c, 1);
            }
            ENDCG
        }
    }
}
