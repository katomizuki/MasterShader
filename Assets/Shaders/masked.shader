Shader "OpaqueStencilMasked"  
{
    // マスクされる側
    Properties  
    {
        _MainTex("-",2D)="white"{}  
    }

    SubShader  
    {
        Tags {"Queue"="Geometry+1"}  
        Pass  
        {
            Stencil {  
                // 
                Ref 2  
                // Refの値(2)と同じ値だったら描画する
                Comp equal  
            }
            ZTest Always  

            CGPROGRAM  
            sampler2D _MainTex;  
            #pragma vertex vert_img  
            #pragma fragment frag  
            #include "UnityCG.cginc"  
            fixed4 frag (v2f_img i) : SV_Target  
            {
                return tex2D(_MainTex, i.uv);  
            }
            ENDCG  
        }

    }
}