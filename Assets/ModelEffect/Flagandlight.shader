Shader "Unlit/Flagandlight"
{
    Properties
    {
      _MainTex ("Texture", 2D) = "white" {}
        _Ambient ("Ambient", Range(0., 1.)) = 0.2
        [Header(Waves)]
        _WaveSpeed("Speed", float) = 0.0
        _WaveStrength("Strength", Range(0.0, 1.0)) = 0.0 
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                fixed4 vertCol : COLOR0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv2 = v.texcoord;
                o.vertCol = v.color;
                return o;
            }

            float _Distance;
            sampler2D _Mask;
            float _Speed;
            fixed _ScrollDirX;
            fixed _ScrollDirY;
            fixed4 _Color;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv + fixed2(_ScrollDirX, _ScrollDirY) * _Speed * _Time.x;
                fixed4 col = tex2D(_MainTex, uv) * _Color * i.vertCol;
                col.a *= tex2D(_Mask, i.uv2).r;
                col.a += 1 - ((i.pos.z / i.pos.w) * _Distance);
                return col;
            }
            ENDCG
        }
    }
}
