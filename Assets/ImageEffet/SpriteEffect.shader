Shader "Unlit/SpriteEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Cull Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= col.a;
                half4 outlineC = _Color;
                outlineC.a *= ceil(col.a);
                outlineC.rgb *= outlineC.a;
                fixed alpha_up = tex2D(_MainTex, i.uv + fixed2(0, _MainTex_ST.y)).a;
                fixed alpha_down = tex2D(_MainTex, i.uv - fixed2(0, _MainTex_ST.y)).a;
                fixed alpha_right = tex2D(_MainTex, i.uv + fixed2(_MainTex_ST.x, 0)).a;
                fixed alpha_left = tex2D(_MainTex, i.uv - fixed2(_MainTex_ST.x, 0)).a;
                return lerp(outlineC, col, ceil(alpha_up * alpha_down * alpha_right * alpha_left));
            }
            ENDCG
        }
    }
}
