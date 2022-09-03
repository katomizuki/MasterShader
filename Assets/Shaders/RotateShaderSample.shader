Shader "Unlit/RotateShaderSample"
{
    Properties
    {
        // オフセット、タイリングの設定なし
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}

        // 回転の速度

        _RotateSpeed ("Rotate Speed", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"

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

            sampler2D _MainTex;
            float _RotateSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Timerを入力として現在の回転角どを作る

                half timer = _Time.x;
                // 回転行列
                half angleCos = cos(timer * _RotateSpeed);
                half angleSin = sin(timer * _RotateSpeed);

                half2x2 rotateMatrix = half2x2(angleCos, -angleSin, angleSin, angleCos);

                half2 uv = i.uv - 0.5;
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
